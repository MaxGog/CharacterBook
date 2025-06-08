import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:docx_template/docx_template.dart' as docx;
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../generated/l10n.dart';
import '../models/custom_field_model.dart';
import '../models/note_model.dart';
import 'character_management_page.dart';
import '../models/character_model.dart';
import '../services/character_qr_service.dart';

class CharacterDetailPage extends StatefulWidget {
  final Character character;

  const CharacterDetailPage({super.key, required this.character});

  @override
  State<CharacterDetailPage> createState() => _CharacterDetailPageState();
}

class _CharacterDetailPageState extends State<CharacterDetailPage> {
  final Map<String, bool> _expandedSections = {
    'basic': true,
    'reference': true,
    'appearance': true,
    'personality': true,
    'biography': true,
    'abilities': true,
    'other': true,
    'customFields': true,
    'additionalImages': true,
    'notes': true,
    'race': true,
  };

  List<Note> _relatedNotes = [];

  Future<void> _exportToDocx() async {
    try {
      final templateData = await rootBundle.load('assets/character_template.docx');
      final templateBytes = templateData.buffer.asUint8List();
      final docxDoc = await docx.DocxTemplate.fromBytes(templateBytes);

      final customFields = widget.character.customFields.toList();
      final additionalImages = widget.character.additionalImages.toList();

      final content = docx.Content()
        ..add(docx.TextContent('name', widget.character.name))
        ..add(docx.TextContent('age', widget.character.age.toString()))
        ..add(docx.TextContent('gender', widget.character.gender))
        ..add(docx.TextContent('biography', widget.character.biography))
        ..add(docx.TextContent('personality', widget.character.personality))
        ..add(docx.TextContent('appearance', widget.character.appearance))
        ..add(docx.TextContent('abilities', widget.character.abilities))
        ..add(docx.TextContent('other', widget.character.other));

      for (var i = 0; i < customFields.length; i++) {
        final field = customFields[i];
        content
          ..add(docx.TextContent('custom_key_$i', field.key))
          ..add(docx.TextContent('custom_value_$i', field.value));
      }

      final generatedDoc = await docxDoc.generate(content);
      if (generatedDoc == null) throw Exception('Ошибка генерации документа');

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/${widget.character.name}_character.docx';
      await File(filePath).writeAsBytes(generatedDoc);

      await OpenFilex.open(filePath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Экспортировано в $filePath')),
        );
      }
    } catch (e) {
      debugPrint('Ошибка экспорта: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка экспорта: ${e.toString()}')),
        );
      }
    }
  }

  void _showShareQRDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Поделиться персонажем'),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Отсканируйте этот QR-код, чтобы получить персонажа:'),
                const SizedBox(height: 20),
                Center(
                  child: CharacterQRService.generateQRCode(widget.character, size: 200),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _showFullImage(Uint8List imageBytes, String title) {
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

  Future<void> _copyToClipboard() async {
    final buffer = StringBuffer()
      ..writeln('Имя: ${widget.character.name}')
      ..writeln('Возраст: ${widget.character.age}')
      ..writeln('Пол: ${widget.character.gender}')
      ..writeln('Биография: ${widget.character.biography}')
      ..writeln('Внешность: ${widget.character.appearance}')
      ..writeln('Характер: ${widget.character.personality}')
      ..writeln('Способности: ${widget.character.abilities}')
      ..writeln('Прочее: ${widget.character.other}');

    if (widget.character.customFields.isNotEmpty) {
      buffer.writeln('\nДополнительные поля:');
      for (final field in widget.character.customFields) {
        buffer.writeln('${field.key}: ${field.value}');
      }
    }

    await Clipboard.setData(ClipboardData(text: buffer.toString()));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Скопировано в буфер обмена')),
      );
    }
  }

  Widget _buildSectionTitle(BuildContext context, String title, String sectionKey) {
    return InkWell(
      onTap: () {
        setState(() {
          _expandedSections[sectionKey] = !_expandedSections[sectionKey]!;
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Icon(
              _expandedSections[sectionKey]! ? Icons.expand_less : Icons.expand_more,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadRelatedNotes() async {
    try {
      final notesBox = await Hive.openBox<Note>('notes');
      final notes = notesBox.values
          .where((note) => note.characterId == widget.character)
          .toList();
      setState(() {
        _relatedNotes = notes;
      });
    } catch (e) {
      debugPrint('Error loading notes: $e');
    }
  }

  Widget _buildSelectableSectionContent(BuildContext context, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SelectableText(
        content.isNotEmpty ? content : 'Нет информации',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildNoteCard(BuildContext context, Note note) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    note.title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${note.updatedAt.day}.${note.updatedAt.month}.${note.updatedAt.year}',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              note.content.length > 100
                  ? '${note.content.substring(0, 100)}...'
                  : note.content,
              style: textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (note.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: note.tags
                    .map((tag) => Chip(
                  label: Text(tag),
                  visualDensity: VisualDensity.compact,
                ))
                    .toList(),
              ),
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
            child: SelectableText(
              value,
              style: textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.character.name,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.qr_code, color: colorScheme.onSurface),
            onPressed: _showShareQRDialog,
            tooltip: 'Поделиться QR-кодом',
          ),
          IconButton(
            icon: Icon(Icons.edit, color: colorScheme.onSurface),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CharacterEditPage(character: widget.character),
              ),
            ),
            tooltip: 'Редактировать',
          ),
          /*IconButton(
            icon: Icon(Icons.file_download, color: colorScheme.onSurface),
            onPressed: _exportToDocx,
            tooltip: 'Экспорт в DOCX',
          ),*/
          IconButton(
            icon: Icon(Icons.copy, color: colorScheme.onSurface),
            onPressed: _copyToClipboard,
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
                  'Обновлено: ${widget.character.lastEdited}',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            ),

            _buildSectionTitle(context, 'Основная информация', 'basic'),
            if (_expandedSections['basic']!) ...[
              Center(
                child: widget.character.imageBytes != null
                    ? InkWell(
                  onTap: () => _showFullImage(
                    widget.character.imageBytes!,
                    'Аватар персонажа',
                  ),
                  child: CircleAvatar(
                    radius: 80,
                    backgroundImage: MemoryImage(widget.character.imageBytes!),
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
              _buildInfoRow(context, 'Имя', widget.character.name),
              _buildInfoRow(context, 'Возраст', '${widget.character.age} лет'),
              _buildInfoRow(context, 'Пол', widget.character.gender),
              _buildInfoRow(context, 'Раса', widget.character.race!.name),
              const SizedBox(height: 16),
            ],

            _buildSectionTitle(context, 'Референс персонажа', 'reference'),
            if (_expandedSections['reference']!) ...[
              Center(
                child: InkWell(
                  onTap: widget.character.referenceImageBytes != null
                      ? () => _showFullImage(
                    widget.character.referenceImageBytes!,
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
                      image: widget.character.referenceImageBytes != null
                          ? DecorationImage(
                        image: MemoryImage(widget.character.referenceImageBytes!),
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                    child: widget.character.referenceImageBytes == null
                        ? Icon(
                      Icons.people,
                      size: 40,
                      color: colorScheme.onSurfaceVariant,
                    )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            _buildSectionTitle(context, 'Внешность', 'appearance'),
            if (_expandedSections['appearance']!) ...[
              _buildSelectableSectionContent(context, widget.character.appearance),
              const SizedBox(height: 16),
            ],

            if (widget.character.additionalImages.isNotEmpty) ...[
              _buildSectionTitle(context, 'Галерея персонажа', 'additionalImages'),
              if (_expandedSections['additionalImages']!) ...[
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: widget.character.additionalImages.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () => _showFullImage(
                        widget.character.additionalImages[index],
                        'Галерея персонажа ${index + 1}',
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          widget.character.additionalImages[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ],

            _buildSectionTitle(context, 'Характер', 'personality'),
            if (_expandedSections['personality']!) ...[
              _buildSelectableSectionContent(context, widget.character.personality),
              const SizedBox(height: 16),
            ],

            _buildSectionTitle(context, 'Биография', 'biography'),
            if (_expandedSections['biography']!) ...[
              _buildSelectableSectionContent(context, widget.character.biography),
              const SizedBox(height: 16),
            ],

            if (widget.character.abilities.isNotEmpty) ...[
              _buildSectionTitle(context, 'Способности', 'abilities'),
              if (_expandedSections['abilities']!) ...[
                _buildSelectableSectionContent(context, widget.character.abilities),
                const SizedBox(height: 16),
              ],
            ],

            if (widget.character.other.isNotEmpty) ...[
              _buildSectionTitle(context, 'Прочее', 'other'),
              if (_expandedSections['other']!) ...[
                _buildSelectableSectionContent(context, widget.character.other),
                const SizedBox(height: 16),
              ],
            ],

            if (widget.character.customFields.isNotEmpty) ...[
              _buildSectionTitle(context, 'Дополнительные поля', 'customFields'),
              if (_expandedSections['customFields']!) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.character.customFields.map((field) => Card(
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
                          SelectableText(
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

            if (_relatedNotes.isNotEmpty) ...[
              _buildSectionTitle(context, 'Связанные посты', 'notes'),
              if (_expandedSections['notes']!) ...[
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _relatedNotes.length,
                  itemBuilder: (context, index) => _buildNoteCard(context, _relatedNotes[index]),
                ),
                const SizedBox(height: 16),
              ],
            ],
          ],
        ),
      ),
    );
  }
}