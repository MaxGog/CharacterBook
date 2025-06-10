import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter/services.dart';

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
  final List<String> _selectedCharacterIds = [];

  @override
  void initState() {
    super.initState();
    final initialTitle = widget.note?.title ?? '';
    _titleController = TextEditingController(
      text: widget.isCopyMode ? 'Копия: $initialTitle' : initialTitle,
    );
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    if (widget.note != null) {
      _selectedCharacterIds.addAll(widget.note!.characterIds);
    }
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
          content: const Text('Заголовок не может быть пустым'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      return;
    }

    final notesBox = Hive.box<Note>('notes');
    final now = DateTime.now();

    if (widget.note != null && !widget.isCopyMode) {
      widget.note!
        ..title = title
        ..content = content
        ..updatedAt = now
        ..characterIds = _selectedCharacterIds;
      await notesBox.put(widget.note!.key, widget.note!);
    } else {
      final note = Note(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        content: content,
        characterIds: _selectedCharacterIds,
      );
      await notesBox.add(note);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(
      text: '${_titleController.text}\n\n${_contentController.text}',
    ));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Скопирован скопирован в буфер'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.note == null
              ? 'Новый пост'
              : widget.isCopyMode
              ? 'Копировать пост'
              : 'Редактировать пост',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_all),
            onPressed: _copyToClipboard,
            tooltip: 'Копировать в буфер',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote,
            tooltip: 'Сохранить',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Заголовок',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.primary),
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              style: textTheme.titleLarge,
              maxLines: 1,
            ),
            const SizedBox(height: 16),
            _buildCharacterSelector(context),
            const SizedBox(height: 16),
            _buildSelectedCharactersChips(context),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: 'Содержание',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.primary),
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.all(16),
                alignLabelWithHint: true,
              ),
              style: textTheme.bodyLarge,
              maxLines: null,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 24),
            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _saveNote,
              child: Text(
                'Сохранить пост',
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacterSelector(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final charactersBox = Hive.box<Character>('characters');
    final characters = charactersBox.values.toList().cast<Character>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: null,
          decoration: InputDecoration(
            labelText: 'Добавить персонажа',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          dropdownColor: colorScheme.surfaceContainerHighest,
          style: textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface,
          ),
          borderRadius: BorderRadius.circular(12),
          items: [
            ...characters.map((character) {
              final characterKey = charactersBox.keyAt(characters.indexOf(character)).toString();
              final isSelected = _selectedCharacterIds.contains(characterKey);
              return DropdownMenuItem(
                value: characterKey,
                child: Row(
                  children: [
                    if (isSelected)
                      Icon(Icons.check, color: colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      character.name,
                      style: textTheme.bodyLarge?.copyWith(
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                if (_selectedCharacterIds.contains(value)) {
                  _selectedCharacterIds.remove(value);
                } else {
                  _selectedCharacterIds.add(value);
                }
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildSelectedCharactersChips(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final charactersBox = Hive.box<Character>('characters');

    if (_selectedCharacterIds.isEmpty) {
      return const SizedBox();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _selectedCharacterIds.map((characterId) {
        final character = charactersBox.get(characterId);
        if (character == null) return const SizedBox();

        return InputChip(
          label: Text(character.name),
          onDeleted: () {
            setState(() {
              _selectedCharacterIds.remove(characterId);
            });
          },
          deleteIcon: Icon(
            Icons.close,
            size: 18,
            color: colorScheme.onSurfaceVariant,
          ),
          backgroundColor: colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }).toList(),
    );
  }
}