import 'package:flutter/material.dart';
import '../../../generated/l10n.dart';

class MarkdownContextMenu extends StatelessWidget {
  final TextEditingController controller;
  final EditableTextState editableTextState;

  const MarkdownContextMenu({
    super.key,
    required this.controller,
    required this.editableTextState,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final textEditingValue = editableTextState.currentTextEditingValue;
    final textSelection = textEditingValue.selection;
    final selectedText = textSelection.textInside(textEditingValue.text);

    return AdaptiveTextSelectionToolbar(
      anchors: editableTextState.contextMenuAnchors,
      children: [
        IconButton(
          icon: const Icon(Icons.format_bold, size: 20),
          onPressed: () => _wrapSelection(controller, '**', '**'),
          tooltip: s.markdown_bold,
        ),
        IconButton(
          icon: const Icon(Icons.format_italic, size: 20),
          onPressed: () => _wrapSelection(controller, '*', '*'),
          tooltip: s.markdown_italic,
        ),
        IconButton(
          icon: const Icon(Icons.format_underline, size: 20),
          onPressed: () => _wrapSelection(controller, '<u>', '</u>'),
          tooltip: s.markdown_underline,
        ),
        IconButton(
          icon: const Icon(Icons.code, size: 20),
          onPressed: () => _wrapSelection(controller, '`', '`'),
          tooltip: s.markdown_inline_code,
        ),
        if (selectedText.contains('\n'))
          IconButton(
            icon: const Icon(Icons.format_quote, size: 20),
            onPressed: () => _wrapSelection(controller, '> ', '', block: true),
            tooltip: s.markdown_quote,
          ),
        IconButton(
          icon: const Icon(Icons.format_list_bulleted, size: 20),
          onPressed: () => _insertAtCursor(controller, '- '),
          tooltip: s.markdown_bullet_list,
        ),
        IconButton(
          icon: const Icon(Icons.format_list_numbered, size: 20),
          onPressed: () => _insertAtCursor(controller, '1. '),
          tooltip: s.markdown_numbered_list,
        ),
        ...editableTextState.contextMenuButtonItems.map((item) {
          return TextButton(
            onPressed: item.onPressed,
            child: Text(item.label ?? ''),
          );
        }),
      ],
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

    controller.value = controller.value.copyWith(
      text: newText,
      selection: newSelection,
    );
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

    controller.value = controller.value.copyWith(
      text: newText,
      selection: newSelection,
    );
  }
}