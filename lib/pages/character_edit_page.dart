import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:hive/hive.dart';
import '../generated/l10n.dart';
import 'package:image_picker/image_picker.dart';

import '../models/character_model.dart';
import 'package:flutter/services.dart';

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

  @override
  void initState() {
    super.initState();
    _initializeFields();
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
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
              onPressed: _copyToClipboard,
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
              // Аватар персонажа
              InkWell(
                borderRadius: BorderRadius.circular(60),
                onTap: _pickImage,
                child: Ink(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.surfaceVariant,
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

              // Основная информация
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(
                  labelText: "Имя",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: textTheme.bodyLarge,
                validator: (value) => value?.isEmpty ?? true ? 'Введите имя' : null,
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: 16),

              // Возраст и пол
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
                        if (value?.isEmpty ?? true) return 'Введите возраст';
                        final age = int.tryParse(value!);
                        if (age == null || age <= 0) return 'Некорректный возраст';
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

              // Референс изображение
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
                    color: colorScheme.surfaceVariant,
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

              // Внешность
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

              const SizedBox(height: 16),

              // Характер
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

              // Биография
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

              // Способности
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
              // Прочее
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

              // Кнопка сохранения
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

  void _saveCharacter() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final box = Hive.box<Character>('characters');

      try {
        final character = Character(
          name: _name,
          age: _age,
          gender: _gender,
          biography: _biography,
          personality: _personality,
          appearance: _appearance,
          imageBytes: _imageBytes,
          abilities: _abilities,
          other: _other,
          referenceImageBytes: _referenceImageBytes,
        );

        if (widget.character != null) {
          await box.put(widget.character!.key, character);
        } else {
          await box.add(character);
        }

        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка сохранения: ${e.toString()}'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }
    }
  }

  Future<void> _copyToClipboard() async {
    final characterInfo = '''
Имя: $_name
Возраст: $_age
Пол: $_gender
Биография: $_biography
Внешность: $_appearance
Характер: $_personality
Способности: $_abilities
Прочее: $_other
''';

    await Clipboard.setData(ClipboardData(text: characterInfo));

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
  }
}