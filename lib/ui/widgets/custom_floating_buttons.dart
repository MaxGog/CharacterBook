import 'package:flutter/material.dart';

class CustomFloatingButtons extends StatelessWidget {
  final VoidCallback? onImport;
  final VoidCallback? onAdd;
  final bool showImportButton;
  final String importTooltip;
  final String addTooltip;
  final VoidCallback? onTemplate;
  final String templateTooltip;

  const CustomFloatingButtons({
    super.key,
    this.onImport,
    this.onAdd,
    this.showImportButton = true,
    this.importTooltip = 'Импорт из файла',
    this.addTooltip = 'Добавить',
    this.onTemplate,
    this.templateTooltip = 'Создать из шаблона',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showImportButton && onImport != null)
          FloatingActionButton(
            heroTag: 'import_btn',
            onPressed: onImport,
            mini: true,
            tooltip: importTooltip,
            child: const Icon(Icons.download),
          ),

        if (showImportButton && onImport != null && onTemplate != null)
          const SizedBox(height: 16),

        if (onTemplate != null)
          FloatingActionButton(
            heroTag: 'template_btn',
            onPressed: onTemplate,
            mini: true,
            tooltip: templateTooltip,
            child: const Icon(Icons.library_books),
          ),

        if ((showImportButton && onImport != null) || onTemplate != null)
          const SizedBox(height: 16),

        if (onAdd != null)
          FloatingActionButton(
            heroTag: 'add_btn',
            tooltip: addTooltip,
            onPressed: onAdd,
            child: const Icon(Icons.add),
          ),
      ],
    );
  }
}