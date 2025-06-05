import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/note_model.dart';
import 'note_edit_page.dart';
import 'settings_page.dart';

class NotesListPage extends StatefulWidget {
  const NotesListPage({super.key});

  @override
  State<NotesListPage> createState() => _NotesListPageState();
}

class _NotesListPageState extends State<NotesListPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Note> _filteredNotes = [];
  bool _isSearching = false;
  String? _selectedTag;

  List<String> _getAllTags(List<Note> notes) {
    final tags = notes.expand((note) => note.tags).toSet().toList()..sort();
    return tags;
  }

  void _filterNotes(String query, List<Note> allNotes) {
    setState(() {
      _filteredNotes = allNotes.where((note) {
        final matchesSearch = query.isEmpty ||
            note.title.toLowerCase().contains(query.toLowerCase()) ||
            note.content.toLowerCase().contains(query.toLowerCase());

        final matchesTag = _selectedTag == null || note.tags.contains(_selectedTag);

        return matchesSearch && matchesTag;
      }).toList();
    });
  }

  Future<void> _deleteNote(Note note, BuildContext context) async {
    final box = Hive.box<Note>('notes');
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить заметку?'),
        content: Text('Заметка "${note.title}" будет удалена безвозвратно'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Удалить',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    ) ?? false;

    if (shouldDelete) {
      await box.delete(note.key);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Заметка "${note.title}" удалена'),
          action: SnackBarAction(
            label: 'Отменить',
            onPressed: () {
              box.add(note);
            },
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
        title: _isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Поиск по заметкам...',
            border: InputBorder.none,
            hintStyle: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          style: textTheme.bodyLarge,
          onChanged: (query) {
            final box = Hive.box<Note>('notes');
            final allNotes = box.values.toList().cast<Note>();
            _filterNotes(query, allNotes);
          },
        )
            : Text(
          'Мои посты',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _selectedTag = null;
                  _filteredNotes = [];
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SettingsPage(),
              ),
            ),
          ),
        ],
      ),
      body: ValueListenableBuilder<Box<Note>>(
        valueListenable: Hive.box<Note>('notes').listenable(),
        builder: (context, box, _) {
          final allNotes = box.values.toList().cast<Note>();
          allNotes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          final tags = _getAllTags(allNotes);

          return Column(
            children: [
              if (tags.isNotEmpty)
                Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: tags.length,
                    itemBuilder: (context, index) {
                      final tag = tags[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          label: Text(tag),
                          selected: _selectedTag == tag,
                          onSelected: (selected) {
                            setState(() {
                              _selectedTag = selected ? tag : null;
                              _filterNotes(_searchController.text, allNotes);
                            });
                          },
                          shape: StadiumBorder(
                            side: BorderSide(
                              color: colorScheme.outline,
                            ),
                          ),
                          showCheckmark: false,
                          side: BorderSide.none,
                          selectedColor: colorScheme.secondaryContainer,
                          labelStyle: textTheme.labelLarge?.copyWith(
                            color: _selectedTag == tag
                                ? colorScheme.onSecondaryContainer
                                : colorScheme.onSurface,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              Expanded(
                child: _buildNotesList(
                  _isSearching || _selectedTag != null ? _filteredNotes : allNotes,
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const NoteEditPage(),
          ),
        ),
      ),
    );
  }

  Widget _buildNotesList(List<Note> notes) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (notes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note_add_outlined,
              size: 64,
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _isSearching && _searchController.text.isNotEmpty
                  ? 'Ничего не найдено'
                  : 'Нет постов',
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isSearching && _searchController.text.isNotEmpty
                  ? 'Попробуйте изменить параметры поиска'
                  : 'Нажмите + чтобы создать первый пост',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return Dismissible(
          key: Key(note.id),
          background: Container(
            color: colorScheme.errorContainer,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: Icon(
              Icons.delete_outline,
              color: colorScheme.onErrorContainer,
            ),
          ),
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Удалить заметку?'),
                content: Text('Заметка "${note.title}" будет удалена безвозвратно'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Отмена'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(
                      'Удалить',
                      style: TextStyle(color: colorScheme.error),
                    ),
                  ),
                ],
              ),
            );
          },
          onDismissed: (direction) async {
            await _deleteNote(note, context);
          },
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteEditPage(note: note),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            note.title,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete,
                              color: colorScheme.onSurface.withOpacity(0.5)),
                          onPressed: () => _deleteNote(note, context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      note.content,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.8),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (note.tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        children: note.tags.map((tag) {
                          return Chip(
                            label: Text(tag),
                            labelStyle: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSecondaryContainer,
                            ),
                            backgroundColor: colorScheme.secondaryContainer,
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}