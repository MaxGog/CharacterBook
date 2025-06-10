import 'package:characterbook/pages/race_management_page.dart';
import 'package:flutter/material.dart';

import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';

import '../models/character_model.dart';
import 'package:flutter/services.dart';

import '../models/custom_field_model.dart';
import '../models/race_model.dart';
import '../services/clipboard_service.dart';

class CharacterEditPage extends StatefulWidget {
  final Character? character;

  const CharacterEditPage({super.key, this.character});

  @override
  State<CharacterEditPage> createState() => _CharacterEditPageState();
}

class _CharacterEditPageState extends State<CharacterEditPage> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late int _age;
  late String _gender;
  late String _biography;
  late String _personality;
  late String _appearance;
  late Uint8List? _imageBytes;
  late String _abilities;
  late String _other;
  late Uint8List? _referenceImageBytes;

  final ImagePicker _picker = ImagePicker();
  final List<String> _genders = ["Мужской", "Женский", "Другой"];

  late List<CustomField> _customFields;
  late List<Uint8List> _additionalImages;

  Race? _selectedRace;
  List<Race> _races = [];

  @override
  void initState() {
    super.initState();
    _initializeFields();
    _loadRaces();
  }

  void _initializeFields() {
    if (widget.character != null) {
      _name = widget.character!.name;
      _age = widget.character!.age;
      _gender = widget.character!.gender;
      _biography = widget.character!.biography;
      _personality = widget.character!.personality;
      _appearance = widget.character!.appearance;
      _imageBytes = widget.character!.imageBytes;
      _abilities = widget.character!.abilities;
      _other = widget.character!.other;
      _referenceImageBytes = widget.character!.referenceImageBytes;
      _customFields = widget.character!.customFields
          .map((f) => CustomField(f.key, f.value))
          .toList();
      _additionalImages = List.from(widget.character!.additionalImages);
      _selectedRace = widget.character!.race;
    } else {
      _name = '';
      _age = 20;
      _gender = _genders.first;
      _biography = '';
      _personality = '';
      _appearance = '';
      _imageBytes = null;
      _abilities = '';
      _other = '';
      _referenceImageBytes = null;
      _customFields = [];
      _additionalImages = [];
      _selectedRace = null;
    }
  }

  Future<void> _loadRaces() async {
    final raceBox = Hive.box<Race>('races');
    setState(() {
      _races = raceBox.values.toList();
      if (widget.character?.race != null) {
        _selectedRace = _races.firstWhere(
              (r) => r.name == widget.character?.race?.name,
          orElse: () => widget.character!.race!,
        );
      }
    });
  }

  Future<void> _saveChanges() async {
    try {
      final box = Hive.box<Character>('characters');
      if (widget.character != null && widget.character!.key != null) {
        await box.put(
            widget.character!.key,
            _buildCharacter()
        );
      }
    } catch (e) {
      debugPrint('Ошибка автосохранения: $e');
    }
  }

  Character _buildCharacter() {
    return Character(
      name: _name,
      age: _age,
      gender: _gender,
      biography: _biography,
      personality: _personality,
      appearance: _appearance,
      abilities: _abilities,
      other: _other,
      imageBytes: _imageBytes,
      referenceImageBytes: _referenceImageBytes,
      customFields: _customFields.where((f) => f.key.isNotEmpty).toList(),
      additionalImages: _additionalImages,
      race: _selectedRace,
    );
  }

  void _addCustomField() {
    setState(() {
      final hasEmpty = _customFields.any((f) =>
      f.key.isEmpty && f.value.isEmpty);
      if (!hasEmpty) {
        _customFields.add(CustomField('', ''));
      }
    });
  }


  void _updateCustomField(int index, String key, String value) {
    setState(() {
      if (key
          .trim()
          .isEmpty && value
          .trim()
          .isEmpty) {
        _customFields.removeAt(index);
      } else {
        _customFields[index] = CustomField(key.trim(), value.trim());
      }
    });
  }

  void _removeCustomField(int index) {
    setState(() {
      _customFields.removeAt(index);
      _saveChanges();
    });
  }

  Widget _buildRaceSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<Race>(
                value: _selectedRace,
                decoration: InputDecoration(
                  labelText: 'Раса',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _races.map((race) {
                  return DropdownMenuItem<Race>(
                    value: race,
                    child: Text(race.name),
                  );
                }).toList(),
                onChanged: (race) {
                  setState(() {
                    _selectedRace = race;
                  });
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RaceManagementPage(),
                  ),
                );
                if (result == true) {
                  await _loadRaces();
                }
              },
              tooltip: 'Управление расами',
            ),
          ],
        ),
        if (_selectedRace != null) ...[
          const SizedBox(height: 8),
          Text(
            _selectedRace!.description,
            style: Theme
                .of(context)
                .textTheme
                .bodyMedium,
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme
        .of(context)
        .colorScheme;
    final textTheme = Theme
        .of(context)
        .textTheme;

    return WillPopScope(
        onWillPop: () async {
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
              if (widget.character != null)
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: _copyToClipboard(),
                  tooltip: 'Копировать',
                ),
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
                  InkWell(
                    borderRadius: BorderRadius.circular(60),
                    onTap: _pickImage,
                    child: Ink(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.surfaceContainerHighest,
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.transparent,
                        backgroundImage: _imageBytes != null
                            ? MemoryImage(_imageBytes!)
                            : null,
                        child: _imageBytes == null
                            ? Icon(
                          Icons.add_a_photo,
                          size: 40,
                          color: colorScheme.onSurfaceVariant,
                        )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  TextFormField(
                    initialValue: _name,
                    decoration: InputDecoration(
                      labelText: "Имя",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    style: textTheme.bodyLarge,
                    validator: (value) =>
                    value?.isEmpty ?? true
                        ? 'Введите имя'
                        : null,
                    onSaved: (value) => _name = value!,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: _age.toString(),
                          decoration: InputDecoration(
                            labelText: 'Возраст',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          style: textTheme.bodyLarge,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Введите возраст';
                            }
                            final age = int.tryParse(value!);
                            if (age == null || age <= 0) {
                              return 'Некорректный возраст';
                            }
                            return null;
                          },
                          onSaved: (value) => _age = int.parse(value!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _gender,
                          items: _genders.map((gender) {
                            return DropdownMenuItem(
                              value: gender,
                              child: Text(gender),
                            );
                          }).toList(),
                          decoration: InputDecoration(
                            labelText: 'Пол',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          style: textTheme.bodyLarge,
                          dropdownColor: colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          onChanged: (value) => _gender = value!,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  _buildRaceSelector(),
                  const SizedBox(height: 16),
                  Text(
                    'Референс персонажа',
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                    ),
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
                        image: _referenceImageBytes != null
                            ? DecorationImage(
                          image: MemoryImage(_referenceImageBytes!),
                          fit: BoxFit.cover,
                        )
                            : null,
                      ),
                      child: _referenceImageBytes == null
                          ? Icon(
                        Icons.add_a_photo,
                        size: 40,
                        color: colorScheme.onSurfaceVariant,
                      )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    initialValue: _appearance,
                    decoration: InputDecoration(
                      labelText: 'Внешность',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignLabelWithHint: true,
                    ),
                    style: textTheme.bodyLarge,
                    maxLines: 5,
                    onSaved: (value) => _appearance = value!,
                  ),

                  Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            'Дополнительные изображения',
                            style: textTheme.titleMedium,
                          ),
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
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
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
                        itemBuilder: (context, index) {
                          return Stack(
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
                                  icon: const Icon(
                                      Icons.delete, color: Colors.red),
                                  onPressed: () =>
                                      _removeAdditionalImage(index),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    initialValue: _personality,
                    decoration: InputDecoration(
                      labelText: 'Характер',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignLabelWithHint: true,
                    ),
                    style: textTheme.bodyLarge,
                    maxLines: 4,
                    onSaved: (value) => _personality = value!,
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    initialValue: _biography,
                    decoration: InputDecoration(
                      labelText: 'Биография',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignLabelWithHint: true,
                    ),
                    style: textTheme.bodyLarge,
                    maxLines: 7,
                    onSaved: (value) => _biography = value!,
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    initialValue: _abilities,
                    decoration: InputDecoration(
                      labelText: 'Способности',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignLabelWithHint: true,
                    ),
                    style: textTheme.bodyLarge,
                    maxLines: 3,
                    onSaved: (value) => _abilities = value!,
                  ),

                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _other,
                    decoration: InputDecoration(
                      labelText: 'Прочее',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignLabelWithHint: true,
                    ),
                    style: textTheme.bodyLarge,
                    maxLines: 5,
                    onSaved: (value) => _other = value!,
                  ),
                  const SizedBox(height: 32),

                  Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            'Дополнительные поля',
                            style: textTheme.titleMedium,
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _addCustomField,
                            tooltip: 'Добавить поле',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ..._customFields
                          .asMap()
                          .entries
                          .map((entry) {
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
                                  decoration: InputDecoration(
                                    labelText: 'Название поля',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onChanged: (value) =>
                                      _updateCustomField(
                                      index, value, field.value),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 3,
                                child: TextFormField(
                                  initialValue: field.value,
                                  decoration: InputDecoration(
                                    labelText: 'Значение',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onChanged: (value) =>
                                      _updateCustomField(
                                      index, field.key, value),
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
                  ),

                  FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _saveCharacter,
                    child: Text(
                      'Сохранить',
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() => _imageBytes = bytes);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при выборе изображения: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  Future<void> _pickReferenceImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() => _referenceImageBytes = bytes);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при выборе изображения: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  Future<void> _pickAdditionalImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _additionalImages.add(bytes);
        });
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

  void _saveCharacter() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        final box = Hive.box<Character>('characters');
        final character = Character(
            name: _name,
            age: _age,
            gender: _gender,
            biography: _biography,
            personality: _personality,
            appearance: _appearance,
            abilities: _abilities,
            other: _other,
            imageBytes: _imageBytes,
            referenceImageBytes: _referenceImageBytes,
            customFields: _customFields.where((f) => f.key.isNotEmpty).toList(),
            additionalImages: _additionalImages,
            lastEdited: DateTime.now(),
            race: _selectedRace
        );

        if (widget.character != null && widget.character!.key != null) {
          await box.put(widget.character!.key, character);
        } else {
          await box.add(character);
        }

        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка сохранения: ${e.toString()}')),
          );
        }
      }
    }
  }

  VoidCallback _copyToClipboard() {
    return () async {
      try {
        await ClipboardService.copyCharacterToClipboard(
          name: _name,
          age: _age,
          gender: _gender,
          raceName: _selectedRace?.name,
          biography: _biography,
          appearance: _appearance,
          personality: _personality,
          abilities: _abilities,
          other: _other,
          customFields: _customFields
              .map((f) => {'key': f.key, 'value': f.value})
              .toList(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Информация скопирована в буфер обмена'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка копирования: ${e.toString()}'),
            ),
          );
        }
      }
    };
  }
}