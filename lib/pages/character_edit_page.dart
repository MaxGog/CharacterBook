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

  final List<String> _genders = ["male", "female", "another"];

  @override
  void initState() {
    super.initState();

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

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _imageBytes = bytes;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при выборе изображения: ${e.toString()}')),
      );
    }
  }

  Future<void> _pickReferenceImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _referenceImageBytes = bytes;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при выборе изображения: ${e.toString()}')),
      );
    }
  }

  void _saveCharacter() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final Uint8List? imageBytes = _imageBytes != null
          ? Uint8List.fromList(_imageBytes!)
          : null;

      final box = Hive.box<Character>('characters');

      try {
        if (widget.character != null) {
          await box.put(widget.character!.key, Character(
            name: _name,
            age: _age,
            gender: _gender,
            biography: _biography,
            personality: _personality,
            appearance: _appearance,
            imageBytes: imageBytes,
            abilities: _abilities,
            other: _other,
            referenceImageBytes: _referenceImageBytes,
          ));
        } else {
          await box.add(Character(
            name: _name,
            age: _age,
            gender: _gender,
            biography: _biography,
            personality: _personality,
            appearance: _appearance,
            imageBytes: imageBytes,
            abilities: _abilities,
            other: _other,
            referenceImageBytes: _referenceImageBytes,
          ));
        }

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

  Future<void> _copyToClipboard() async {
    final characterInfo = '${S.of(context).name}: ${_name}\n'
        '${S.of(context).age}: ${_age}\n'
        '${S.of(context).gender}: ${_gender}\n'
        '${S.of(context).biography}: ${_biography}\n'
        '${S.of(context).appearance}: ${_appearance}\n'
        '${S.of(context).personality}: ${_personality}\n'
        '${"Способности: "}: ${_abilities}\n'
        '${"Прочее: "}: ${_other}\n';
    await Clipboard.setData(ClipboardData(text: characterInfo));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Информация скопирована в буфер обмена')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.character == null ? S.of(context).new_character : S.of(context).edit),
        centerTitle: true,
        actions: [
          if (widget.character != null) // Only show copy button when editing existing character
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: _copyToClipboard,
              tooltip: S.of(context).copy,
            ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveCharacter,
            tooltip: S.of(context).save,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _imageBytes != null
                      ? MemoryImage(_imageBytes!)
                      : null,
                  child: _imageBytes == null
                      ? const Icon(Icons.add_a_photo, size: 40)
                      : null,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: "Имя"),
                validator: (value) => value?.isEmpty ?? true ? 'Введите имя' : null,
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _age.toString(),
                      decoration: const InputDecoration(labelText: 'Возраст'),
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
                      decoration: const InputDecoration(labelText: 'Пол'),
                      onChanged: (value) => _gender = value!,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _biography,
                decoration: const InputDecoration(labelText: 'Биография'),
                maxLines: 3,
                onSaved: (value) => _biography = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _personality,
                decoration: const InputDecoration(labelText: 'Характер'),
                maxLines: 3,
                onSaved: (value) => _personality = value!,
              ),
              const SizedBox(height: 16),
              const Text("Референс персонажа"),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickReferenceImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _referenceImageBytes != null
                      ? MemoryImage(_referenceImageBytes!)
                      : null,
                  child: _referenceImageBytes == null
                      ? const Icon(Icons.add_a_photo, size: 40)
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _appearance,
                decoration: const InputDecoration(labelText: 'Внешность'),
                maxLines: 3,
                onSaved: (value) => _appearance = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _abilities,
                decoration: const InputDecoration(labelText: 'Способности'),
                maxLines: 3,
                onSaved: (value) => _abilities = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _other,
                decoration: const InputDecoration(labelText: 'Прочее'),
                maxLines: 3,
                onSaved: (value) => _other = value!,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: _saveCharacter,
                child: const Text('Сохранить', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}