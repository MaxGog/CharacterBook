import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:docx_template/docx_template.dart' as docx;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

import '../generated/l10n.dart';

import 'character_edit_page.dart';
import '../models/character_model.dart';

class CharacterDetailPage extends StatelessWidget {
  final Character character;

  const CharacterDetailPage({super.key, required this.character});

  Future<void> _exportToDocx(BuildContext context) async {
    try {
      final docxDoc = await docx.DocxTemplate.fromBytes(Uint8List(0));
      final data = {
        'name': character.name,
        'age': character.age.toString(),
        'gender': character.gender,
        'biography': character.biography,
        'personality': character.personality,
        'appearance': character.appearance,
      };

      await docxDoc.generate(data as docx.Content);
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/${character.name}_character.docx';

      final file = await File(filePath).writeAsBytes((docxDoc) as List<int>);
      await OpenFile.open(file.path);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Персонаж экспортирован в $filePath'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при экспорте: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  Future<void> _copyToClipboard(BuildContext context) async {
    final characterInfo = '''
Имя: ${character.name}
Возраст: ${character.age} лет
Пол: ${character.gender}
Биография: ${character.biography}
Внешность: ${character.appearance}
Характер: ${character.personality}
Способности: ${character.abilities}
Прочее: ${character.other}
''';

    await Clipboard.setData(ClipboardData(text: characterInfo));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Информация скопирована в буфер обмена'),
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
          character.name,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: colorScheme.onSurface),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CharacterEditPage(character: character),
              ),
            ),
            tooltip: 'Редактировать',
          ),
          IconButton(
            icon: Icon(Icons.file_download, color: colorScheme.onSurface),
            onPressed: () => _exportToDocx(context),
            tooltip: 'Экспорт в DOCX',
          ),
          IconButton(
            icon: Icon(Icons.copy, color: colorScheme.onSurface),
            onPressed: () => _copyToClipboard(context),
            tooltip: 'Копировать',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Аватар персонажа
            Center(
              child: character.imageBytes != null
                  ? CircleAvatar(
                radius: 80,
                backgroundImage: MemoryImage(character.imageBytes!),
              )
                  : CircleAvatar(
                radius: 80,
                backgroundColor: colorScheme.surfaceVariant,
                child: Icon(
                  Icons.person,
                  size: 60,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Основная информация
            _buildInfoRow(context, 'Имя', character.name),
            _buildInfoRow(context, 'Возраст', '${character.age} лет'),
            _buildInfoRow(context, 'Пол', character.gender),
            const SizedBox(height: 16),

            _buildSectionTitle(context, 'Референс персонажа'),
            Center(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                child: Ink(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    image: character.referenceImageBytes != null
                        ? DecorationImage(
                      image: MemoryImage(character.referenceImageBytes!),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: character.referenceImageBytes == null
                      ? Icon(
                    Icons.people,
                    size: 40,
                    color: colorScheme.onSurfaceVariant,
                  )
                      : null,
                ),
              ),
            ),

            // Внешность
            _buildSectionTitle(context, 'Внешность'),
            _buildSectionContent(context, character.appearance),
            const SizedBox(height: 16),

            // Характер
            _buildSectionTitle(context, 'Характер'),
            _buildSectionContent(context, character.personality),
            const SizedBox(height: 16),

            // Биография
            _buildSectionTitle(context, 'Биография'),
            _buildSectionContent(context, character.biography),
            const SizedBox(height: 16),

            // Способности
            if (character.abilities.isNotEmpty) ...[
              _buildSectionTitle(context, 'Способности'),
              _buildSectionContent(context, character.abilities),
              const SizedBox(height: 16),
            ],

            // Прочее
            if (character.other.isNotEmpty) ...[
              _buildSectionTitle(context, 'Прочее'),
              _buildSectionContent(context, character.other),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildSectionContent(BuildContext context, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        content.isNotEmpty ? content : 'Нет информации',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}