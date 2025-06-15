import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

import '../models/character_model.dart';
import '../models/custom_field_model.dart';
import '../models/race_model.dart';

import '../widgets/avatar_picker_widget.dart';
import '../widgets/fields/custom_fields_editor.dart';
import '../widgets/fields/custom_text_field.dart';
import '../widgets/fields/gender_selector_field.dart';
import '../widgets/fields/race_selector_field.dart';
import '../widgets/save_button_widget.dart';
import '../widgets/unsaved_changes_dialog.dart';

class CharacterEditPage extends StatefulWidget {
  final Character? character;

  const CharacterEditPage({super.key, this.character});

  @override
  State<CharacterEditPage> createState() => _CharacterEditPageState();
}

class _CharacterEditPageState extends State<CharacterEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  late Character _character;
  late List<Race> _races;
  late List<CustomField> _customFields;
  late List<Uint8List> _additionalImages;

  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
    _loadRaces();
    _hasUnsavedChanges = widget.character == null;
  }

  void _initializeFields() {
    _character = widget.character?.copyWith() ?? Character.empty();
    _customFields = _character.customFields.map((f) => f.copyWith()).toList();
    _additionalImages = List.from(_character.additionalImages);
  }

  Future<void> _loadRaces() async {
    final raceBox = Hive.box<Race>('races');
    setState(() {
      _races = raceBox.values.toList();
      if (_character.race != null) {
        final foundRace = _races.firstWhere(
              (r) => r.name == _character.race?.name,
          orElse: () => Race.empty(),
        );

        _character.race = foundRace.name.isNotEmpty ? foundRace : _character.race;
      }
    });
  }

  Future<void> _saveChanges() async {
    try {
      final box = Hive.box<Character>('characters');
      if (widget.character != null && widget.character!.key != null) {
        await box.put(widget.character!.key, _buildCharacter());
      }
    } catch (e) {
      debugPrint('Ошибка автосохранения: $e');
    }
  }

  Character _buildCharacter() {
    return _character.copyWith(
      customFields: _customFields.where((f) => f.key.isNotEmpty).toList(),
      additionalImages: _additionalImages,
    );
  }

  Future<void> _pickReferenceImage() async => _pickAndSetImage(false);

  Future<void> _pickAndSetImage(bool isMainImage) async {
    try {
      final image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          if (isMainImage) {
            _character.imageBytes = bytes;
          } else {
            _character.referenceImageBytes = bytes;
          }
        });
      }
    } catch (e) {
      _showError('Ошибка при выборе изображения: ${e.toString()}');
    }
  }

  Future<void> _pickAdditionalImage() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() => _additionalImages.add(bytes));
      }
    } catch (e) {
      _showError('Ошибка при выборе изображения: ${e.toString()}');
    }
  }

  void _removeAdditionalImage(int index) {
    setState(() => _additionalImages.removeAt(index));
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _saveCharacter() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        final box = Hive.box<Character>('characters');
        final character = _buildCharacter();

        if (widget.character != null && widget.character!.key != null) {
          await box.put(widget.character!.key, character);
        } else {
          await box.add(character);
        }

        setState(() => _hasUnsavedChanges = false);

        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка сохранения: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return WillPopScope(
      onWillPop: () async {
        if (!_hasUnsavedChanges) return true;

        final shouldSave = await UnsavedChangesDialog().show(context);
        if (shouldSave == null) return false;

        if (shouldSave) {
          await _saveCharacter();
          if (mounted) return true;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.character == null ? 'Новый персонаж' : 'Редактировать',
            style: textTheme.titleLarge,
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveCharacter,
              tooltip: 'Сохранить',
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                AvatarPicker(
                  imageBytes: _character.imageBytes,
                  onImageSelected: (bytes) {
                    setState(() {
                      _character.imageBytes = bytes;
                      _hasUnsavedChanges = true;
                    });
                    _saveChanges();
                  },
                  radius: 60,
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  label: 'Имя',
                  initialValue: _character.name,
                  isRequired: true,
                  onSaved: (value) => _character.name = value!,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Возраст',
                        initialValue: _character.age.toString(),
                        isRequired: true,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Введите возраст';
                          final age = int.tryParse(value!);
                          if (age == null || age <= 0) return 'Некорректный возраст';
                          return null;
                        },
                        onSaved: (value) => _character.age = int.parse(value!),
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: GenderSelectorField(
                        initialValue: _character.gender,
                        onChanged: (value) => _character.gender = value!,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                RaceSelectorField(
                  initialRace: _character.race,
                  onChanged: (race) => _character.race = race,
                ),
                const SizedBox(height: 16),
                _buildReferenceImageSection(context, colorScheme, textTheme),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Внешность',
                  initialValue: _character.appearance,
                  alignLabel: true,
                  onSaved: (value) => _character.appearance = value!,
                  maxLines: 5,
                ),
                _buildAdditionalImagesSection(context, textTheme, colorScheme),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Характер',
                  initialValue: _character.personality,
                  alignLabel: true,
                  onSaved: (value) => _character.personality = value!,
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Биография',
                  initialValue: _character.biography,
                  alignLabel: true,
                  onSaved: (value) => _character.biography = value!,
                  maxLines: 7,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Способности',
                  initialValue: _character.abilities,
                  alignLabel: true,
                  onSaved: (value) => _character.abilities = value!,
                  maxLines: 7,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Прочее',
                  initialValue: _character.other,
                  alignLabel: true,
                  onSaved: (value) => _character.other = value!,
                  maxLines: 5,
                ),
                const SizedBox(height: 32),
                CustomFieldsEditor(
                  initialFields: _customFields,
                  onFieldsChanged: (fields) => _customFields = fields,
                ),
                SaveButton(
                  onPressed: _saveCharacter,
                  text: 'Сохранить персонажа',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReferenceImageSection(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      children: [
        Text(
          'Референс персонажа',
          style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
        ),
        const SizedBox(height: 8),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _pickReferenceImage,
          child: Ink(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              image: _character.referenceImageBytes != null
                  ? DecorationImage(
                image: MemoryImage(_character.referenceImageBytes!),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: _character.referenceImageBytes == null
                ? Icon(
              Icons.add_a_photo,
              size: 40,
              color: colorScheme.onSurfaceVariant,
            )
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalImagesSection(BuildContext context, TextTheme textTheme, ColorScheme colorScheme) {
    return Column(
      children: [
        Row(
          children: [
            Text('Дополнительные изображения', style: textTheme.titleMedium),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.add_photo_alternate),
              onPressed: _pickAdditionalImage,
              tooltip: 'Добавить изображение',
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_additionalImages.isEmpty)
          Text(
            'Нет дополнительных изображений',
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _additionalImages.length,
          itemBuilder: (context, index) => Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  _additionalImages[index],
                  fit: BoxFit.cover,
                  height: 120,
                  width: double.infinity,
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeAdditionalImage(index),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

}