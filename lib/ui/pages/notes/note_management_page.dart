import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../generated/l10n.dart';
import '../../../models/character_model.dart';
import '../../../models/note_model.dart';
import '../../../services/clipboard_service.dart';
import '../../widgets/fields/custom_text_field.dart';
import '../../widgets/markdown_context_menu.dart';
import '../../widgets/save_button_widget.dart';
import '../../widgets/unsaved_changes_dialog.dart';

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
  bool _isPreviewMode = false;
  final GlobalKey _contentFieldKey = GlobalKey();
  bool _hasChanges = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final initialTitle = widget.note?.title ?? '';
    _titleController = TextEditingController(
      text: widget.isCopyMode ? '${S.of(context).copy}: $initialTitle' : initialTitle,
    );
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _selectedCharacterIds.addAll(widget.note?.characterIds ?? []);
    _isPreviewMode = widget.note != null && !widget.isCopyMode;

    _titleController.addListener(_checkForChanges);
    _contentController.addListener(_checkForChanges);
  }

  void _checkForChanges() {
    final hasTitleChanges = widget.note?.title != _titleController.text;
    final hasContentChanges = widget.note?.content != _contentController.text;
    setState(() {
      _hasChanges = hasTitleChanges || hasContentChanges;
    });
  }

  @override
  void dispose() {
    _titleController.removeListener(_checkForChanges);
    _contentController.removeListener(_checkForChanges);
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).save_error)),
      );
      return;
    }

    final notesBox = Hive.box<Note>('notes');
    final now = DateTime.now();

    if (widget.note != null && !widget.isCopyMode) {
      widget.note!
        ..title = title
        ..content = _contentController.text.trim()
        ..characterIds = _selectedCharacterIds
        ..updatedAt = now;
      await notesBox.put(widget.note!.key, widget.note!);
    } else {
      await notesBox.add(Note(
        id: now.millisecondsSinceEpoch.toString(),
        title: title,
        content: _contentController.text.trim(),
        characterIds: _selectedCharacterIds,
      ));
    }

    setState(() => _hasChanges = false);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _copyToClipboard() async {
    final charactersBox = Hive.box<Character>('characters');
    final characterNames = _selectedCharacterIds.map((id) {
      final character = charactersBox.get(id);
      return character?.name ?? S.of(context).no_data_found;
    }).toList();

    await ClipboardService.copyNoteToClipboard(
      title: _titleController.text,
      content: _contentController.text,
      characterNames: characterNames.isNotEmpty ? characterNames : null,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).operationCompleted)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return WillPopScope(
      onWillPop: () async {
        if (!_hasChanges) return true;
        final shouldSave = await UnsavedChangesDialog(
          saveText: S.of(context).save,
        ).show(context);
        if (shouldSave == null) return false;
        if (shouldSave) await _saveNote();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.note == null
                ? S.of(context).create
                : widget.isCopyMode
                ? '${S.of(context).copy} ${S.of(context).posts.toLowerCase()}'
                : S.of(context).edit,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.copy_all),
              onPressed: _copyToClipboard,
              tooltip: S.of(context).copy,
            ),
            IconButton(
              icon: Icon(_isPreviewMode ? Icons.edit : Icons.preview),
              onPressed: () => setState(() => _isPreviewMode = !_isPreviewMode),
              tooltip: _isPreviewMode ? S.of(context).edit : S.of(context).empty_list,
            ),
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveNote,
              tooltip: S.of(context).save,
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: _buildContent(context),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            controller: _titleController,
            label: S.of(context).name,
            isRequired: true,
            onChanged: (value) => _checkForChanges(),
          ),
          const SizedBox(height: 16),
          _buildCharacterSelector(context),
          const SizedBox(height: 16),
          _buildSelectedCharactersChips(context),
          const SizedBox(height: 16),
          _buildContentField(),
          const SizedBox(height: 24),
          SaveButton(
            onPressed: _saveNote,
            text: S.of(context).save,
          ),
        ],
      ),
    );
  }

  Widget _buildContentField() {
    if (_isPreviewMode) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: MarkdownBody(
          data: _contentController.text,
          styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)),
        ),
      );
    }

    return CustomTextField(
      key: _contentFieldKey,
      controller: _contentController,
      label: '${S.of(context).description} (${S.of(context).no_content})',
      maxLines: null,
      alignLabel: true,
      keyboardType: TextInputType.multiline,
      onChanged: (value) => _checkForChanges(),
      contextMenuBuilder: (context, editableTextState) {
        return MarkdownContextMenu(
          controller: _contentController,
          editableTextState: editableTextState,
        );
      },
    );
  }

  Widget _buildCharacterSelector(BuildContext context) {
    final characters = Hive.box<Character>('characters').values.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: null,
          decoration: InputDecoration(
            labelText: '${S.of(context).create} ${S.of(context).character.toLowerCase()}',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          dropdownColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          style: Theme.of(context).textTheme.bodyLarge,
          borderRadius: BorderRadius.circular(12),
          items: characters.map((character) {
            final characterKey = Hive.box<Character>('characters')
                .keyAt(characters.indexOf(character))
                .toString();
            final isSelected = _selectedCharacterIds.contains(characterKey);
            return DropdownMenuItem(
              value: characterKey,
              child: Row(
                children: [
                  if (isSelected)
                    Icon(Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20),
                  const SizedBox(width: 8),
                  Text(
                    character.name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedCharacterIds.contains(value)
                    ? _selectedCharacterIds.remove(value)
                    : _selectedCharacterIds.add(value);
                _hasChanges = true;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildSelectedCharactersChips(BuildContext context) {
    final charactersBox = Hive.box<Character>('characters');

    if (_selectedCharacterIds.isEmpty) return const SizedBox();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _selectedCharacterIds.map((characterId) {
        final character = charactersBox.get(characterId);
        return character != null
            ? _buildCharacterChip(character, characterId)
            : const SizedBox();
      }).toList(),
    );
  }

  Widget _buildCharacterChip(Character character, String characterId) {
    return InputChip(
      label: Text(character.name),
      onDeleted: () => setState(() {
        _selectedCharacterIds.remove(characterId);
        _hasChanges = true;
      }),
      deleteIcon: Icon(
        Icons.close,
        size: 18,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}