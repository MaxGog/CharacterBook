import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/character_model.dart';
import '../models/note_model.dart';
import '../models/race_model.dart';
import '../services/clipboard_service.dart';
import '../services/character_export_service.dart';

class ContextMenu extends StatelessWidget {
  final dynamic item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool showExportPdf;
  final bool showCopy;
  final bool showShare;

  const ContextMenu({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
    this.showExportPdf = false,
    this.showCopy = true,
    this.showShare = true,
  });

  factory ContextMenu.character({
    required Character character,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    Key? key,
  }) {
    return ContextMenu(
      key: key,
      item: character,
      onEdit: onEdit,
      onDelete: onDelete,
      showExportPdf: true,
    );
  }

  factory ContextMenu.race({
    required Race race,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    Key? key,
  }) {
    return ContextMenu(
      key: key,
      item: race,
      onEdit: onEdit,
      onDelete: onDelete,
    );
  }

  factory ContextMenu.note({
    required Note note,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    Key? key,
  }) {
    return ContextMenu(
      key: key,
      item: note,
      onEdit: onEdit,
      onDelete: onDelete,
    );
  }

  Future<void> _copyToClipboard(BuildContext context) async {
    try {
      if (item is Character) {
        final character = item as Character;
        await ClipboardService.copyCharacterToClipboard(
          name: character.name,
          age: character.age,
          gender: character.gender,
          raceName: character.race?.name,
          biography: character.biography,
          appearance: character.appearance,
          personality: character.personality,
          abilities: character.abilities,
          other: character.other,
          customFields: character.customFields.map((f) => {'key': f.key, 'value': f.value}).toList(),
        );
      } else if (item is Race) {
        final race = item as Race;
        await ClipboardService.copyRaceToClipboard(
          name: race.name,
          description: race.description,
          biology: race.biology,
          backstory: race.backstory,
        );
      } else if (item is Note) {
        final note = item as Note;
        await Clipboard.setData(ClipboardData(text: note.content));
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Данные скопированы в буфер'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка копирования: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _exportToPdf(BuildContext context) async {
    if (item is! Character) return;

    try {
      await CharacterExportService(item as Character).exportToPdf();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF успешно экспортирован'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка экспорта в PDF: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _shareAsFile(BuildContext context) async {
    try {
      String fileName;
      String content;

      if (item is Character) {
        final character = item as Character;
        fileName = '${character.name}.character';
        content = jsonEncode(character.toJson());
      } else if (item is Race) {
        final race = item as Race;
        fileName = '${race.name}.race';
        content = jsonEncode(race.toJson());
      } else if (item is Note) {
        final note = item as Note;
        fileName = '${note.title}_note.json';
        content = jsonEncode(note.toJson());
      } else {
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(content);
      await Share.shareXFiles([XFile(file.path)], text: fileName);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.edit, color: theme.colorScheme.onSurface),
            title: Text('Редактировать', style: theme.textTheme.bodyLarge),
            onTap: () {
              Navigator.pop(context);
              onEdit();
            },
          ),
          if (showCopy) ...[
            Divider(height: 1, color: theme.colorScheme.surfaceContainerHighest),
            ListTile(
              leading: Icon(Icons.copy, color: theme.colorScheme.onSurface),
              title: Text('Копировать данные', style: theme.textTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                _copyToClipboard(context);
              },
            ),
          ],
          if (showExportPdf) ...[
            Divider(height: 1, color: theme.colorScheme.surfaceContainerHighest),
            ListTile(
              leading: Icon(Icons.picture_as_pdf, color: theme.colorScheme.onSurface),
              title: Text('Экспорт в PDF', style: theme.textTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                _exportToPdf(context);
              },
            ),
          ],
          if (showShare) ...[
            Divider(height: 1, color: theme.colorScheme.surfaceContainerHighest),
            ListTile(
              leading: Icon(Icons.share, color: theme.colorScheme.onSurface),
              title: Text('Поделиться файлом', style: theme.textTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                _shareAsFile(context);
              },
            ),
          ],
          Divider(height: 1, color: theme.colorScheme.surfaceContainerHighest),
          ListTile(
            leading: Icon(Icons.delete, color: theme.colorScheme.error),
            title: Text('Удалить', style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.error,
            )),
            onTap: () {
              Navigator.pop(context);
              onDelete();
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}