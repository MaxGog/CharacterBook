import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:docx_template/docx_template.dart' as docx;
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../generated/l10n.dart';

import '../models/custom_field_model.dart';
import 'character_edit_page.dart';
import '../models/character_model.dart';

class CharacterDetailPage extends StatelessWidget {
  final Character character;

  const CharacterDetailPage({super.key, required this.character});

  Future<void> _exportToDocx(BuildContext context) async {
    try {
      final templateData = await rootBundle.load('assets/character_template.docx');
      final templateBytes = templateData.buffer.asUint8List();
      final docxDoc = await docx.DocxTemplate.fromBytes(templateBytes);

      final customFields = List<CustomField>.from(character.customFields);
      final additionalImages = List<Uint8List>.from(character.additionalImages);

      final content = docx.Content()
        ..add(docx.TextContent('name', character.name))
        ..add(docx.TextContent('age', character.age.toString()))
        ..add(docx.TextContent('gender', character.gender))
        ..add(docx.TextContent('biography', character.biography))
        ..add(docx.TextContent('personality', character.personality))
        ..add(docx.TextContent('appearance', character.appearance))
        ..add(docx.TextContent('abilities', character.abilities))
        ..add(docx.TextContent('other', character.other));

      for (var i = 0; i < customFields.length; i++) {
        final field = customFields[i];
        content
          ..add(docx.TextContent('custom_key_$i', field.key))
          ..add(docx.TextContent('custom_value_$i', field.value));
      }

      final generatedDoc = await docxDoc.generate(content);
      if (generatedDoc == null) throw Exception('Ошибка генерации документа');

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/${character.name}_character.docx';
      await File(filePath).writeAsBytes(generatedDoc);

      await OpenFilex.open(filePath);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Экспортировано в $filePath')),
        );
      }
    } catch (e) {
      debugPrint('Ошибка экспорта: $e'); // Добавьте логирование
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка экспорта: ${e.toString()}')),
        );
      }
    }
  }

  void _showFullImage(BuildContext context, Uint8List imageBytes, String title) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              backgroundColor: Colors.black.withOpacity(0.5),
              title: Text(title),
              actions: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.1,
              maxScale: 4.0,
              child: Image.memory(imageBytes),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _copyToClipboard(BuildContext context) async {
    final buffer = StringBuffer()
      ..writeln('Имя: ${character.name}')
      ..writeln('Возраст: ${character.age}')
      ..writeln('Пол: ${character.gender}')
      ..writeln('Биография: ${character.biography}')
      ..writeln('Внешность: ${character.appearance}')
      ..writeln('Характер: ${character.personality}')
      ..writeln('Способности: ${character.abilities}')
      ..writeln('Прочее: ${character.other}');

    if (character.customFields.isNotEmpty) {
      buffer.writeln('\nДополнительные поля:');
      for (final field in character.customFields) {
        buffer.writeln('${field.key}: ${field.value}');
      }
    }

    await Clipboard.setData(ClipboardData(text: buffer.toString()));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Скопировано в буфер обмена')),
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

            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Обновлено: ${character.lastEdited}',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            ),

            Center(
              child: character.imageBytes != null
                  ? InkWell(
                onTap: () => _showFullImage(
                  context,
                  character.imageBytes!,
                  'Аватар персонажа',
                ),
                child: CircleAvatar(
                  radius: 80,
                  backgroundImage: MemoryImage(character.imageBytes!),
                ),
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
                onTap: character.referenceImageBytes != null
                    ? () => _showFullImage(
                  context,
                  character.referenceImageBytes!,
                  'Референс персонажа',
                )
                    : null,
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

            if (character.additionalImages.isNotEmpty) ...[
              _buildSectionTitle(context, 'Дополнительные изображения'),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: character.additionalImages.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () => _showFullImage(
                      context,
                      character.additionalImages[index],
                      'Дополнительное изображение ${index + 1}',
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        character.additionalImages[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],

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

            if (character.customFields.isNotEmpty) ...[
              _buildSectionTitle(context, 'Дополнительные поля'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: character.customFields.map((field) => Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          field.key,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          field.value,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                )).toList(),
              ),
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