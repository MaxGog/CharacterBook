import 'package:flutter/material.dart';
import '../../../generated/l10n.dart';

class UnsavedChangesDialog extends StatelessWidget {
  final String? title;
  final String? content;
  final String? saveText;
  final String? discardText;
  final String? cancelText;

  const UnsavedChangesDialog({
    super.key,
    this.title,
    this.content,
    this.saveText,
    this.discardText,
    this.cancelText,
  });

  Future<bool?> show(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => this,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return AlertDialog(
      title: Text(title ?? s.unsaved_changes_title),
      content: Text(content ?? s.unsaved_changes_content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(discardText ?? s.discard_changes),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(saveText ?? s.save),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: Text(cancelText ?? s.cancel),
        ),
      ],
    );
  }
}