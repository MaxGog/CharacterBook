import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/character_model.dart';

class CharacterEditPage extends StatefulWidget {
  final Character? character;

  const CharacterEditPage({super.key, this.character});

  @override
  _CharacterEditPageState createState() => _CharacterEditPageState();
}

class _CharacterEditPageState extends State<CharacterEditPage> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late int _age;
  late String _gender;
  late String _biography;
  late String _personality;
  late String _appearance;

  final List<String> _genders = ['Мужской', 'Женский', 'Другой'];

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
    } else {
      _name = '';
      _age = 20;
      _gender = _genders.first;
      _biography = '';
      _personality = '';
      _appearance = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.character == null ? 'Новый персонаж' : 'Редактировать'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Имя'),
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
              TextFormField(
                initialValue: _appearance,
                decoration: const InputDecoration(labelText: 'Внешность'),
                maxLines: 3,
                onSaved: (value) => _appearance = value!,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                child: const Text('Сохранить'),
                onPressed: _saveCharacter,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveCharacter() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final character = Character(
        name: _name,
        age: _age,
        gender: _gender,
        biography: _biography,
        personality: _personality,
        appearance: _appearance,
      );

      final box = Hive.box<Character>('characters');

      if (widget.character != null) {
        final box = Hive.box<Character>('characters');
        await box.add(character);
      } else {
        await box.add(character);
      }

      Navigator.pop(context);
    }
  }
}