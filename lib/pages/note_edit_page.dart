import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart'; // Для Clipboard

import '../models/character_model.dart';
import '../models/note_model.dart';

class NoteEditPage extends StatefulWidget {
  final Note? note;
  final bool isCopyMode;

  const NoteEditPage({super.key, this.note, this.isCopyMode = false});

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
    final initialTitle = widget.note?.title ?? '';
    _titleController = TextEditingController(
      text: widget.isCopyMode ? 'Копия: $initialTitle' : initialTitle,
    );
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
        SnackBar(
          content: Text('Заголовок не может быть пустым'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final notesBox = Hive.box<Note>('notes');
    final now = DateTime.now();

    if (widget.note != null && !widget.isCopyMode) {
      // Редактирование существующей заметки
      widget.note!
        ..title = title
        ..content = content
        ..updatedAt = now
        ..characterId = _selectedCharacterId;
      await notesBox.put(widget.note!.key, widget.note!);
    } else {
      // Создание новой заметки или копии
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

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(
      text: '${_titleController.text}\n\n${_contentController.text}',
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Заметка скопирована в буфер'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.note == null ? 'Новая заметка' :
          widget.isCopyMode ? 'Копировать заметку' : 'Редактировать заметку',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (widget.note != null && !widget.isCopyMode)
            IconButton(
              icon: Icon(Icons.copy),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NoteEditPage(
                      note: widget.note,
                      isCopyMode: true,
                    ),
                  ),
                );
              },
            ),
          IconButton(
            icon: Icon(Icons.copy_all),
            onPressed: _copyToClipboard,
          ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Заголовок',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colorScheme.primary),
                ),
                filled: true,
                fillColor: colorScheme.surfaceVariant,
              ),
              style: textTheme.titleLarge,
              maxLines: 1,
            ),
            const SizedBox(height: 16),
            _buildCharacterSelector(context),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: 'Содержание',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colorScheme.primary),
                ),
                filled: true,
                fillColor: colorScheme.surfaceVariant,
                contentPadding: const EdgeInsets.all(16),
              ),
              style: textTheme.bodyLarge,
              maxLines: null,
              keyboardType: TextInputType.multiline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacterSelector(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final charactersBox = Hive.box<Character>('characters');
    final characters = charactersBox.values.toList().cast<Character>();

    return DropdownButtonFormField<String>(
      value: _selectedCharacterId,
      decoration: InputDecoration(
        labelText: 'Персонаж (необязательно)',
        border: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        filled: true,
        fillColor: colorScheme.surfaceVariant,
      ),
      dropdownColor: colorScheme.surfaceVariant,
      style: TextStyle(color: colorScheme.onSurface),
      items: [
        DropdownMenuItem(
          value: null,
          child: Text(
            'Не привязано к персонажу',
            style: TextStyle(color: colorScheme.onSurface),
          ),
        ),
        ...characters.map((character) {
          final characterKey = charactersBox.keyAt(characters.indexOf(character)).toString();
          return DropdownMenuItem(
            value: characterKey,
            child: Text(
              character.name,
              style: TextStyle(color: colorScheme.onSurface),
            ),
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