import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../../models/character_model.dart';
import '../../../models/note_model.dart';
import '../../../services/character_export_service.dart';
import '../../../services/clipboard_service.dart';
import 'character_management_page.dart';

class CharacterDetailPage extends StatefulWidget {
  final Character character;
  const CharacterDetailPage({super.key, required this.character});

  @override
  State<CharacterDetailPage> createState() => _CharacterDetailPageState();
}

class _CharacterDetailPageState extends State<CharacterDetailPage> {
  final _expandedSections = <String, bool>{
    'basic': true, 'reference': true, 'appearance': true,
    'personality': true, 'biography': true, 'abilities': true,
    'other': true, 'customFields': true, 'additionalImages': true,
    'notes': true, 'race': true,
  };

  List<Note> _relatedNotes = [];

  @override
  void initState() {
    super.initState();
    _loadRelatedNotes();
  }

  Future<void> _loadRelatedNotes() async {
    if (!mounted) return;

    try {
      final notesBox = await Hive.openBox<Note>('notes');
      _relatedNotes = notesBox.values
          .where((note) => note.characterIds.contains(widget.character.key.toString()))
          .toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } catch (e) {
      debugPrint('Ошибка загрузки связанных постов: $e');
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _confirmDelete() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить персонажа?'),
        content: const Text('Вы уверены, что хотите удалить этого персонажа? Это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      _deleteCharacter();
    }
  }

  void _deleteCharacter() async {
    try {
      if (widget.character.key != null) {
        final box = Hive.box<Character>('characters');
        await box.delete(widget.character.key);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Персонаж удален')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при удалении: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _exportToPdf() async {
    try {
      final exportService = CharacterExportService(widget.character);
      await exportService.exportToPdf();
      _showSnackBar('PDF успешно экспортирован', isError: false);
    } catch (e) {
      _showSnackBar('Ошибка экспорта: ${e.toString()}');
    }
  }

  Future<void> _exportToJson() async {
    try {
      final exportService = CharacterExportService(widget.character);
      await exportService.exportToJson();
      _showSnackBar('Файл готов к отправке', isError: false);
    } catch (e) {
      _showSnackBar('Ошибка экспорта: ${e.toString()}');
    }
  }

  Future<void> _copyToClipboard() async {
    try {
      await ClipboardService.copyCharacterToClipboard(
        name: widget.character.name,
        age: widget.character.age,
        gender: widget.character.gender,
        raceName: widget.character.race?.name,
        biography: widget.character.biography,
        appearance: widget.character.appearance,
        personality: widget.character.personality,
        abilities: widget.character.abilities,
        other: widget.character.other,
        customFields: widget.character.customFields
            .map((field) => {'key': field.key, 'value': field.value})
            .toList(),
      );
      _showSnackBar('Скопировано в буфер обмена', isError: false);
    } catch (e) {
      _showSnackBar('Ошибка копирования: ${e.toString()}');
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showFullImage(Uint8List imageBytes, String title) => showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBar(
            backgroundColor: Colors.black,
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

  Widget _buildSectionTitle(String title, String sectionKey, IconData icon) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => setState(() => _expandedSections[sectionKey] = !_expandedSections[sectionKey]!),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Icon(
              _expandedSections[sectionKey]! ? Icons.expand_less : Icons.expand_more,
              color: theme.colorScheme.onSurface,
            ),
            const SizedBox(width: 8),
            Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectableContent(String content) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SelectableText(
        content.isNotEmpty ? content : 'Нет информации',
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildNoteCard(Note note) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${note.updatedAt.day}.${note.updatedAt.month}.${note.updatedAt.year}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              note.content.length > 100 ? '${note.content.substring(0, 100)}...' : note.content,
              style: theme.textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (note.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: note.tags.map((tag) => Chip(label: Text(tag))).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: SelectableText(value, style: theme.textTheme.bodyLarge)),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final theme = Theme.of(context);
    return widget.character.imageBytes != null
        ? InkWell(
      onTap: () => _showFullImage(widget.character.imageBytes!, 'Аватар персонажа'),
      child: CircleAvatar(
        radius: 80,
        backgroundImage: MemoryImage(widget.character.imageBytes!),
      ),
    )
        : CircleAvatar(
      radius: 80,
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.person,
        size: 60,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildReferenceImage() {
    final theme = Theme.of(context);
    return InkWell(
      onTap: widget.character.referenceImageBytes != null
          ? () => _showFullImage(widget.character.referenceImageBytes!, 'Референс персонажа')
          : null,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          image: widget.character.referenceImageBytes != null
              ? DecorationImage(
            image: MemoryImage(widget.character.referenceImageBytes!),
            fit: BoxFit.cover,
          )
              : null,
        ),
        child: widget.character.referenceImageBytes == null
            ? Icon(Icons.people, size: 40, color: theme.colorScheme.onSurfaceVariant)
            : null,
      ),
    );
  }

  Widget _buildGallery() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: widget.character.additionalImages.length,
      itemBuilder: (context, index) => InkWell(
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
      ),
    );
  }

  Widget _buildCustomFields() {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.character.customFields.map((field) => Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                field.key,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              SelectableText(
                field.value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.character.name,
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.share, color: colorScheme.onSurface),
            onSelected: (value) => switch (value) {
              'file' => _exportToJson(),
              'pdf' => _exportToPdf(),
              _ => null,
            },
            tooltip: 'Поделиться персонажем',
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'file', child: Text('Файл (.character)')),
              PopupMenuItem(value: 'pdf', child: Text('Документ PDF (.pdf)')),
            ],
          ),
          IconButton(
              icon: Icon(Icons.copy, color: colorScheme.onSurface),
              onPressed: _copyToClipboard,
              tooltip: 'Скопировать персонажа'
          ),
          IconButton(
              icon: Icon(Icons.edit, color: colorScheme.onSurface),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CharacterEditPage(character: widget.character),
                ),
              ),
              tooltip: 'Редактировать персонажа'
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _confirmDelete,
            tooltip: 'Удалить персонажа',
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
              child: Text(
                'Обновлено: ${widget.character.lastEdited}',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 16),

            _buildSectionTitle('Основная информация', 'basic', Icons.info),
            if (_expandedSections['basic']!) ...[
              Center(child: _buildAvatar()),
              const SizedBox(height: 24),
              _buildInfoRow('Имя', widget.character.name, Icons.badge),
              _buildInfoRow('Возраст', '${widget.character.age} лет', Icons.cake),
              _buildInfoRow('Пол', widget.character.gender, Icons.transgender),
              if (widget.character.race != null)
                _buildInfoRow('Раса', widget.character.race!.name, Icons.people),
              const SizedBox(height: 16),
            ],

            _buildSectionTitle('Референс персонажа', 'reference', Icons.image_search),
            if (_expandedSections['reference']!) ...[
              Center(child: _buildReferenceImage()),
              const SizedBox(height: 16),
            ],

            _buildSection('Внешность', 'appearance', widget.character.appearance, Icons.face_retouching_natural),
            _buildSection('Характер', 'personality', widget.character.personality, Icons.psychology),
            _buildSection('Биография', 'biography', widget.character.biography, Icons.history_edu),
            if (widget.character.abilities.isNotEmpty)
              _buildSection('Способности', 'abilities', widget.character.abilities, Icons.auto_awesome),
            if (widget.character.other.isNotEmpty)
              _buildSection('Прочее', 'other', widget.character.other, Icons.more_horiz),

            if (widget.character.additionalImages.isNotEmpty) ...[
              _buildSectionTitle('Галерея персонажа', 'additionalImages', Icons.photo_library),
              if (_expandedSections['additionalImages']!) ...[
                _buildGallery(),
                const SizedBox(height: 16),
              ],
            ],

            if (widget.character.customFields.isNotEmpty) ...[
              _buildSectionTitle('Дополнительные поля', 'customFields', Icons.list_alt),
              if (_expandedSections['customFields']!) ...[
                _buildCustomFields(),
                const SizedBox(height: 16),
              ],
            ],

            if (_relatedNotes.isNotEmpty) ...[
              _buildSectionTitle('Связанные посты', 'notes', Icons.note),
              if (_expandedSections['notes']!) ...[
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _relatedNotes.length,
                  itemBuilder: (context, index) => _buildNoteCard(_relatedNotes[index]),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String key, String content, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title, key, icon),
        if (_expandedSections[key]!) ...[
          _buildSelectableContent(content),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}