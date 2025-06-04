import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../models/character_model.dart';
import '../models/note_model.dart';

class NoteEditPage extends StatefulWidget {
  final Note? note;

  const NoteEditPage({super.key, this.note});

  @override
  State<NoteEditPage> createState() => _NoteEditPageState();
}

class _NoteEditPageState extends State<NoteEditPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  String? _selectedCharacterId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _selectedCharacterId = widget.note?.characterId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Заголовок не может быть пустым')),
      );
      return;
    }

    final notesBox = Hive.box<Note>('notes');
    final now = DateTime.now();

    if (widget.note != null) {
      widget.note!
        ..title = title
        ..content = content
        ..updatedAt = now
        ..characterId = _selectedCharacterId;
      await widget.note!.save();
    } else {
      final note = Note(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        content: content,
        characterId: _selectedCharacterId,
      );
      await notesBox.add(note);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Новая заметка' : 'Редактировать заметку'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Заголовок',
                border: OutlineInputBorder(),
              ),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            _buildCharacterSelector(),
            SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: 'Содержание',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
              keyboardType: TextInputType.multiline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacterSelector() {
    final charactersBox = Hive.box<Character>('characters');
    final characters = charactersBox.values.toList().cast<Character>();

    return DropdownButtonFormField<String>(
      value: _selectedCharacterId,
      decoration: InputDecoration(
        labelText: 'Персонаж (необязательно)',
        border: OutlineInputBorder(),
      ),
      items: [
        DropdownMenuItem(
          value: null,
          child: Text('Не привязано к персонажу'),
        ),
        ...characters.map((character) {
          final characterKey = charactersBox.keyAt(characters.indexOf(character)).toString();
          return DropdownMenuItem(
            value: characterKey,
            child: Text(character.name),
          );
        }),
      ],
      onChanged: (value) {
        setState(() {
          _selectedCharacterId = value;
        });
      },
    );
  }
}