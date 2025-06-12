import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

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
  bool _isPreviewMode = false;
  final GlobalKey _contentFieldKey = GlobalKey();
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final initialTitle = widget.note?.title ?? '';
    _titleController = TextEditingController(
      text: widget.isCopyMode ? 'Копия: $initialTitle' : initialTitle,
    );
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _selectedCharacterIds.addAll(widget.note?.characterIds ?? []);
    _isPreviewMode = widget.note != null && !widget.isCopyMode;

    // Добавляем слушатели изменений
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

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Есть несохраненные изменения'),
        content: const Text('Хотите сохранить изменения перед выходом?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Не сохранять'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );

    if (shouldSave == true) {
      await _saveNote();
    }
    return true;
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      _showSnackBar('Заголовок не может быть пустым');
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
    await Clipboard.setData(ClipboardData(
      text: '${_titleController.text}\n\n${_contentController.text}',
    ));
    if (mounted) _showSnackBar('Текст скопирован в буфер');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.note == null
                ? 'Новый пост'
                : widget.isCopyMode
                ? 'Копировать пост'
                : 'Редактировать пост',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.copy_all),
              onPressed: _copyToClipboard,
              tooltip: 'Копировать в буфер',
            ),
            IconButton(
              icon: Icon(_isPreviewMode ? Icons.edit : Icons.preview),
              onPressed: () => setState(() => _isPreviewMode = !_isPreviewMode),
              tooltip: _isPreviewMode ? 'Редактировать' : 'Предпросмотр',
            ),
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveNote,
              tooltip: 'Сохранить',
            ),
          ],
        ),
        body: _buildContent(context, colorScheme, textTheme),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTitleField(colorScheme, textTheme),
          const SizedBox(height: 16),
          _buildCharacterSelector(context),
          const SizedBox(height: 16),
          _buildSelectedCharactersChips(context),
          const SizedBox(height: 16),
          _buildContentField(colorScheme, textTheme),
          const SizedBox(height: 24),
          _buildSaveButton(colorScheme, textTheme),
        ],
      ),
    );
  }

  Widget _buildTitleField(ColorScheme colorScheme, TextTheme textTheme) {
    return TextField(
      controller: _titleController,
      decoration: _buildInputDecoration(
        colorScheme,
        labelText: 'Заголовок',
      ),
      style: textTheme.titleLarge,
      maxLines: 1,
    );
  }

  Widget _buildContentField(ColorScheme colorScheme, TextTheme textTheme) {
    if (_isPreviewMode) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: MarkdownBody(
          data: _contentController.text,
          styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
            p: textTheme.bodyLarge,
            h1: textTheme.displayLarge,
            h2: textTheme.displayMedium,
            h3: textTheme.displaySmall,
            h4: textTheme.headlineMedium,
            h5: textTheme.headlineSmall,
            h6: textTheme.titleLarge,
            blockquote: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
            code: textTheme.bodyLarge?.copyWith(
              backgroundColor: colorScheme.surfaceContainerHighest,
              fontFamily: 'monospace',
            ),
          ),
        ),
      );
    }

    return TextField(
      key: _contentFieldKey,
      controller: _contentController,
      decoration: _buildInputDecoration(
        colorScheme,
        labelText: 'Содержание (поддерживается Markdown)',
        contentPadding: const EdgeInsets.all(16),
        alignLabelWithHint: true,
      ),
      style: textTheme.bodyLarge,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      contextMenuBuilder: (context, editableTextState) {
        final textEditingValue = editableTextState.currentTextEditingValue;
        final textSelection = textEditingValue.selection;
        final selectedText = textSelection.textInside(textEditingValue.text);

        return AdaptiveTextSelectionToolbar(
          anchors: editableTextState.contextMenuAnchors,
          children: [
            ...editableTextState.contextMenuButtonItems.map((item) {
              return TextButton(
                onPressed: item.onPressed,
                child: Text(item.label ?? ''),
              );
            }),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.format_bold, size: 20),
              onPressed: () => _wrapSelection(_contentController, '**', '**'),
              tooltip: 'Жирный',
            ),
            IconButton(
              icon: const Icon(Icons.format_italic, size: 20),
              onPressed: () => _wrapSelection(_contentController, '*', '*'),
              tooltip: 'Курсив',
            ),
            IconButton(
              icon: const Icon(Icons.format_underline, size: 20),
              onPressed: () => _wrapSelection(_contentController, '<u>', '</u>'),
              tooltip: 'Подчеркнутый',
            ),
            IconButton(
              icon: const Icon(Icons.code, size: 20),
              onPressed: () => _wrapSelection(_contentController, '`', '`'),
              tooltip: 'Код (inline)',
            ),
            if (selectedText.contains('\n'))
              IconButton(
                icon: const Icon(Icons.format_quote, size: 20),
                onPressed: () => _wrapSelection(_contentController, '> ', '', block: true),
                tooltip: 'Цитата',
              ),
            IconButton(
              icon: const Icon(Icons.format_list_bulleted, size: 20),
              onPressed: () => _insertAtCursor(_contentController, '- '),
              tooltip: 'Маркированный список',
            ),
            IconButton(
              icon: const Icon(Icons.format_list_numbered, size: 20),
              onPressed: () => _insertAtCursor(_contentController, '1. '),
              tooltip: 'Нумерованный список',
            ),
          ],
        );
      },
    );
  }

  void _wrapSelection(
      TextEditingController controller,
      String prefix,
      String suffix, {
        bool block = false,
      }) {
    final text = controller.text;
    final selection = controller.selection;
    final selectedText = selection.textInside(text);

    String newText;
    TextSelection newSelection;

    if (block) {
      final lines = selectedText.split('\n');
      final modifiedLines = lines.map((line) => '$prefix$line').join('\n');
      newText = text.replaceRange(selection.start, selection.end, modifiedLines);
      newSelection = TextSelection(
        baseOffset: selection.start,
        extentOffset: selection.start + modifiedLines.length,
      );
    } else {
      newText = text.replaceRange(selection.start, selection.end, '$prefix$selectedText$suffix');
      newSelection = TextSelection(
        baseOffset: selection.start,
        extentOffset: selection.start + prefix.length + selectedText.length + suffix.length,
      );
    }

    setState(() {
      controller.value = controller.value.copyWith(
        text: newText,
        selection: newSelection,
      );
    });
  }

  void _insertAtCursor(TextEditingController controller, String textToInsert) {
    final selection = controller.selection;
    final newText = controller.text.replaceRange(
      selection.start,
      selection.end,
      selection.textInside(controller.text).isEmpty
          ? textToInsert
          : '$textToInsert${selection.textInside(controller.text)}',
    );

    final newSelection = TextSelection.collapsed(
      offset: selection.start + textToInsert.length,
    );

    setState(() {
      controller.value = controller.value.copyWith(
        text: newText,
        selection: newSelection,
      );
    });
  }

  InputDecoration _buildInputDecoration(
      ColorScheme colorScheme, {
        required String labelText,
        EdgeInsetsGeometry? contentPadding,
        bool? alignLabelWithHint,
      }) {
    return InputDecoration(
      labelText: labelText,
      border: _buildInputBorder(colorScheme.outline),
      enabledBorder: _buildInputBorder(colorScheme.outline),
      focusedBorder: _buildInputBorder(colorScheme.primary),
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest,
      contentPadding: contentPadding ??
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      alignLabelWithHint: alignLabelWithHint,
    );
  }

  OutlineInputBorder _buildInputBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color),
    );
  }

  Widget _buildSaveButton(ColorScheme colorScheme, TextTheme textTheme) {
    return FilledButton(
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
        style: textTheme.labelLarge?.copyWith(color: colorScheme.onPrimary),
      ),
    );
  }

  Widget _buildCharacterSelector(BuildContext context) {
    final theme = Theme.of(context);
    final characters = Hive.box<Character>('characters').values.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: null,
          decoration: _buildInputDecoration(
            theme.colorScheme,
            labelText: 'Добавить персонажа',
          ),
          dropdownColor: theme.colorScheme.surfaceContainerHighest,
          style: theme.textTheme.bodyLarge,
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
                        color: theme.colorScheme.primary,
                        size: 20),
                  const SizedBox(width: 8),
                  Text(
                    character.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
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
    final theme = Theme.of(context);
    final charactersBox = Hive.box<Character>('characters');

    if (_selectedCharacterIds.isEmpty) return const SizedBox();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _selectedCharacterIds.map((characterId) {
        final character = charactersBox.get(characterId);
        return character != null
            ? _buildCharacterChip(theme, character, characterId)
            : const SizedBox();
      }).toList(),
    );
  }

  Widget _buildCharacterChip(ThemeData theme, Character character, String characterId) {
    return InputChip(
      label: Text(character.name),
      onDeleted: () => setState(() {
        _selectedCharacterIds.remove(characterId);
        _hasChanges = true;
      }),
      deleteIcon: Icon(
        Icons.close,
        size: 18,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}