import 'package:flutter/material.dart';

class UnsavedChangesDialog extends StatelessWidget {
  final String title;
  final String content;
  final String saveText;
  final String discardText;
  final String cancelText;

  const UnsavedChangesDialog({
    super.key,
    this.title = 'Несохраненные изменения',
    this.content = 'У вас есть несохраненные изменения. Хотите сохранить перед выходом?',
    this.saveText = 'Сохранить',
    this.discardText = 'Не сохранять',
    this.cancelText = 'Отмена',
  });

  Future<bool?> show(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(discardText),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(saveText),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: Text(cancelText),
        ),
      ],
    );
  }
}