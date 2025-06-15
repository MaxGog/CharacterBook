import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

import '../models/character_model.dart';
import '../models/custom_field_model.dart';
import '../models/race_model.dart';

import '../widgets/avatar_picker_widget.dart';
import '../widgets/save_button_widget.dart';
import '../widgets/unsaved_changes_dialog.dart';

import 'race_management_page.dart';

class CharacterEditPage extends StatefulWidget {
  final Character? character;

  const CharacterEditPage({super.key, this.character});

  @override
  State<CharacterEditPage> createState() => _CharacterEditPageState();
}

class _CharacterEditPageState extends State<CharacterEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  final _genders = const ["Мужской", "Женский", "Другой"];

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

  void _addCustomField() {
    setState(() {
      final hasEmpty = _customFields.any((f) => f.key.isEmpty && f.value.isEmpty);
      if (!hasEmpty) {
        _customFields.add(CustomField('', ''));
      }
    });
    _hasUnsavedChanges = true;
    _saveChanges();
  }

  void _updateCustomField(int index, String key, String value) {
    setState(() {
      if (key.trim().isEmpty && value.trim().isEmpty) {
        _customFields.removeAt(index);
      } else {
        _customFields[index] = CustomField(key.trim(), value.trim());
      }
      _hasUnsavedChanges = true;
      _saveChanges();
    });
  }

  void _removeCustomField(int index) {
    setState(() {
      _customFields.removeAt(index);
      _saveChanges();
    });
  }

  Widget _buildRaceSelector() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<Race>(
                value: _character.race != null && _races.any((r) => r.name == _character.race?.name)
                    ? _races.firstWhere((r) => r.name == _character.race?.name)
                    : null,
                decoration: InputDecoration(
                  labelText: 'Раса',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: [
                  const DropdownMenuItem<Race>(
                    value: null,
                    child: Text('Не выбрано', style: TextStyle(color: Colors.grey)),
                  ),
                  ..._races.map((race) => DropdownMenuItem<Race>(
                    value: race,
                    child: Text(race.name),
                  )),
                ],
                onChanged: (race) => setState(() => _character.race = race),
                validator: (value) => value == null ? 'Выберите расу' : null,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RaceManagementPage()),
                );
                if (result == true) await _loadRaces();
              },
              tooltip: 'Управление расами',
            ),
          ],
        ),
        if (_character.race != null) ...[
          const SizedBox(height: 8),
          Text(_character.race!.description, style: theme.textTheme.bodyMedium),
        ],
      ],
    );
  }

  Future<void> _pickImage() async => _pickAndSetImage(true);
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
                _buildNameField(textTheme),
                const SizedBox(height: 16),
                _buildAgeAndGenderFields(textTheme),
                const SizedBox(height: 16),
                _buildRaceSelector(),
                const SizedBox(height: 16),
                _buildReferenceImageSection(context, colorScheme, textTheme),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Внешность',
                  value: _character.appearance,
                  maxLines: 5,
                  onSaved: (value) => _character.appearance = value!,
                ),
                _buildAdditionalImagesSection(context, textTheme, colorScheme),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Характер',
                  value: _character.personality,
                  maxLines: 4,
                  onSaved: (value) => _character.personality = value!,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Биография',
                  value: _character.biography,
                  maxLines: 7,
                  onSaved: (value) => _character.biography = value!,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Способности',
                  value: _character.abilities,
                  maxLines: 3,
                  onSaved: (value) => _character.abilities = value!,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Прочее',
                  value: _character.other,
                  maxLines: 5,
                  onSaved: (value) => _character.other = value!,
                ),
                const SizedBox(height: 32),
                _buildCustomFieldsSection(textTheme),
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

  Widget _buildNameField(TextTheme textTheme) {
    return TextFormField(
      initialValue: _character.name,
      decoration: _inputDecoration(label: "Имя"),
      style: textTheme.bodyLarge,
      validator: (value) => value?.isEmpty ?? true ? 'Введите имя' : null,
      onSaved: (value) => _character.name = value!,
    );
  }

  Widget _buildAgeAndGenderFields(TextTheme textTheme) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            initialValue: _character.age.toString(),
            decoration: _inputDecoration(label: 'Возраст'),
            style: textTheme.bodyLarge,
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
          child: DropdownButtonFormField<String>(
            value: _character.gender,
            items: _genders.map((gender) => DropdownMenuItem(
              value: gender,
              child: Text(gender),
            )).toList(),
            decoration: _inputDecoration(label: 'Пол'),
            style: textTheme.bodyLarge,
            dropdownColor: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            onChanged: (value) => _character.gender = value!,
          ),
        ),
      ],
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

  Widget _buildTextField({
    required String label,
    required String value,
    required int maxLines,
    required FormFieldSetter<String> onSaved,
  }) {
    return TextFormField(
      initialValue: value,
      decoration: _inputDecoration(label: label, alignLabel: true),
      style: Theme.of(context).textTheme.bodyLarge,
      maxLines: maxLines,
      onChanged: (_) => setState(() => _hasUnsavedChanges = true),
      onSaved: onSaved,
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

  Widget _buildCustomFieldsSection(TextTheme textTheme) {
    return Column(
      children: [
        Row(
          children: [
            Text('Дополнительные поля', style: textTheme.titleMedium),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addCustomField,
              tooltip: 'Добавить поле',
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._customFields.asMap().entries.map((entry) {
          final index = entry.key;
          final field = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    initialValue: field.key,
                    decoration: _inputDecoration(label: 'Название поля'),
                    onChanged: (value) => _updateCustomField(index, value, field.value),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    initialValue: field.value,
                    decoration: _inputDecoration(label: 'Значение'),
                    onChanged: (value) => _updateCustomField(index, field.key, value),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _removeCustomField(index),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  InputDecoration _inputDecoration({required String label, bool alignLabel = false}) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      alignLabelWithHint: alignLabel,
    );
  }
}