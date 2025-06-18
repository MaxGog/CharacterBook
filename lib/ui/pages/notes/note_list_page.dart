import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../generated/l10n.dart';
import '../../../models/character_model.dart';
import '../../../models/note_model.dart';
import '../../widgets/context_menu.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_floating_buttons.dart';

import 'note_management_page.dart';

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
  String? _selectedCharacter;
  Note? _selectedNote;

  List<String> _getAllTags(List<Note> notes) {
    return notes.expand((note) => note.tags).toSet().toList()..sort();
  }

  List<String> _getAllCharacterNames(List<Note> notes) {
    final characterBox = Hive.box<Character>('characters');
    final characterIds = notes.expand((note) => note.characterIds).toSet();
    return characterIds
        .map((id) => characterBox.get(id))
        .whereType<Character>()
        .map((c) => c.name)
        .toSet()
        .toList()
      ..sort();
  }

  void _filterNotes(String query, List<Note> allNotes) {
    final characterBox = Hive.box<Character>('characters');

    setState(() {
      _filteredNotes = allNotes.where((note) {
        final matchesSearch = query.isEmpty ||
            note.title.toLowerCase().contains(query.toLowerCase()) ||
            note.content.toLowerCase().contains(query.toLowerCase());

        final matchesTag = _selectedTag == null || note.tags.contains(_selectedTag);

        final matchesCharacter = _selectedCharacter == null ||
            note.characterIds.any((id) {
              final character = characterBox.get(id);
              return character?.name == _selectedCharacter;
            });

        return matchesSearch && matchesTag && matchesCharacter;
      }).toList();
    });
  }

  Future<void> _deleteNote(Note note) async {
    final box = Hive.box<Note>('notes');
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).template_delete_title),
        content: Text('${S.of(context).posts} "${note.title}" ${S.of(context).template_delete_confirm}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(S.of(context).cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              S.of(context).delete,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    ) ??
        false;

    if (shouldDelete) {
      await box.delete(note.key);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${S.of(context).posts} "${note.title}" ${S.of(context).template_deleted}'),
          action: SnackBarAction(
            label: S.of(context).cancel,
            onPressed: () => box.add(note),
          ),
        ),
      );
    }
  }

  void _showNoteContextMenu(Note note, BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ContextMenu.note(
        note: note,
        onEdit: () => _editNote(note),
        onDelete: () => _deleteNote(note),
      ),
    );
  }

  Future<void> _editNote(Note note) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => NoteEditPage(note: note)),
    );
    if (result == true && mounted) {
      _filterNotes(_searchController.text, Hive.box<Note>('notes').values.toList().cast<Note>());
    }
  }

  Future<void> _reorderNotes(int oldIndex, int newIndex) async {
    if (oldIndex == newIndex) return;

    final box = Hive.box<Note>('notes');
    final notes = box.values.toList().cast<Note>();

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final note = notes.removeAt(oldIndex);
    notes.insert(newIndex, note);

    await box.clear();
    await box.addAll(notes);

    if (mounted) {
      setState(() {
        _filterNotes(_searchController.text, notes);
      });
    }
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required ValueChanged<bool> onSelected,
    required TextTheme textTheme,
    required ColorScheme colorScheme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: onSelected,
        shape: StadiumBorder(
          side: BorderSide(color: colorScheme.outline),
        ),
        showCheckmark: false,
        side: BorderSide.none,
        selectedColor: colorScheme.secondaryContainer,
        labelStyle: textTheme.labelLarge?.copyWith(
          color: selected
              ? colorScheme.onSecondaryContainer
              : colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildFiltersRow(
      List<String> tags,
      List<String> characterNames,
      TextTheme textTheme,
      ColorScheme colorScheme,
      ) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          if (characterNames.isNotEmpty)
            _buildFilterChip(
              label: '${S.of(context).all} ${S.of(context).characters.toLowerCase()}',
              selected: _selectedCharacter == null,
              onSelected: (isSelected) {
                setState(() {
                  _selectedCharacter = null;
                  _filterNotes(_searchController.text,
                      Hive.box<Note>('notes').values.toList().cast<Note>());
                });
              },
              textTheme: textTheme,
              colorScheme: colorScheme,
            ),
          ...characterNames.map((name) => _buildFilterChip(
            label: name,
            selected: _selectedCharacter == name,
            onSelected: (isSelected) {
              setState(() {
                _selectedCharacter = _selectedCharacter == name ? null : name;
                _filterNotes(_searchController.text,
                    Hive.box<Note>('notes').values.toList().cast<Note>());
              });
            },
            textTheme: textTheme,
            colorScheme: colorScheme,
          )),
          if (tags.isNotEmpty)
            _buildFilterChip(
              label: S.of(context).all_tags,
              selected: _selectedTag == null,
              onSelected: (isSelected) {
                setState(() {
                  _selectedTag = null;
                  _filterNotes(_searchController.text,
                      Hive.box<Note>('notes').values.toList().cast<Note>());
                });
              },
              textTheme: textTheme,
              colorScheme: colorScheme,
            ),
          ...tags.map((tag) => _buildFilterChip(
            label: tag,
            selected: _selectedTag == tag,
            onSelected: (isSelected) {
              setState(() {
                _selectedTag = _selectedTag == tag ? null : tag;
                _filterNotes(_searchController.text,
                    Hive.box<Note>('notes').values.toList().cast<Note>());
              });
            },
            textTheme: textTheme,
            colorScheme: colorScheme,
          )),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_add_outlined,
            size: 64,
            color: colorScheme.onSurface,
          ),
          const SizedBox(height: 16),
          Text(
            _isSearching && _searchController.text.isNotEmpty
                ? S.of(context).nothing_found
                : '${S.of(context).empty_list} ${S.of(context).posts.toLowerCase()}',
            style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            _isSearching && _searchController.text.isNotEmpty
                ? S.of(context).search_hint
                : '${S.of(context).create} ${S.of(context).posts.toLowerCase()}',
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteItem(
      Note note,
      ColorScheme colorScheme,
      TextTheme textTheme, {
        bool isSelected = false,
      }) {
    final characterBox = Hive.box<Character>('characters');
    final characters = note.characterIds
        .map((id) => characterBox.get(id))
        .whereType<Character>()
        .toList();

    return Card(
      key: ValueKey(note.key),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      elevation: 0,
      color: isSelected ? colorScheme.secondaryContainer : colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? colorScheme.secondary : colorScheme.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (MediaQuery.of(context).size.width > 1000) {
            setState(() => _selectedNote = note);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NoteEditPage(note: note)),
            );
          }
        },
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
                    icon: Icon(Icons.more_vert, color: colorScheme.onSurfaceVariant),
                    onPressed: () => _showNoteContextMenu(note, context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                note.content,
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (characters.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  children: characters.map((character) => Chip(
                    label: Text(character.name),
                    labelStyle: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                    ),
                    backgroundColor: colorScheme.secondaryContainer,
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  )).toList(),
                ),
              ],
              if (note.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  children: note.tags.map((tag) => Chip(
                    label: Text(tag),
                    labelStyle: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                    ),
                    backgroundColor: colorScheme.secondaryContainer,
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  )).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotesList(List<Note> notes, ColorScheme colorScheme, TextTheme textTheme) {
    return notes.isEmpty
        ? _buildEmptyState(colorScheme, textTheme)
        : ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: notes.length,
      itemBuilder: (context, index) =>
          _buildNoteItem(notes[index], colorScheme, textTheme),
      onReorder: (oldIndex, newIndex) async {
        await _reorderNotes(oldIndex, newIndex);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isWideScreen = MediaQuery.of(context).size.width > 1000;

    return Scaffold(
        appBar: CustomAppBar(
          title: '${S.of(context).my} ${S.of(context).posts.toLowerCase()}',
          isSearching: _isSearching,
          searchController: _searchController,
          searchHint: S.of(context).search_hint,
          onSearchToggle: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchController.clear();
                _selectedTag = null;
                _selectedCharacter = null;
                _filteredNotes = [];
              }
            });
          },
          onSearchChanged: (query) {
            final allNotes = Hive.box<Note>('notes').values.toList().cast<Note>();
            _filterNotes(query, allNotes);
          },
        ),
        body: ValueListenableBuilder<Box<Note>>(
          valueListenable: Hive.box<Note>('notes').listenable(),
          builder: (context, box, _) {
            final allNotes = box.values.toList().cast<Note>();
            allNotes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
            final tags = _getAllTags(allNotes);
            final characterNames = _getAllCharacterNames(allNotes);

            return isWideScreen
                ? _buildWideLayout(allNotes, tags, characterNames, colorScheme, textTheme)
                : _buildMobileLayout(allNotes, tags, characterNames, colorScheme, textTheme);
          },
        ),
        floatingActionButton: CustomFloatingButtons(
          showImportButton: false,
          onAdd: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NoteEditPage()),
          ),
        )
    );
  }

  Widget _buildWideLayout(
      List<Note> allNotes,
      List<String> tags,
      List<String> characterNames,
      ColorScheme colorScheme,
      TextTheme textTheme,
      ) {
    final notes = _isSearching || _selectedTag != null || _selectedCharacter != null
        ? _filteredNotes
        : allNotes;

    return Row(
      children: [
        Container(
          width: 400,
          decoration: BoxDecoration(
            border: Border(right: BorderSide(color: colorScheme.outline)),
          ),
          child: Column(
            children: [
              if (tags.isNotEmpty || characterNames.isNotEmpty)
                _buildFiltersRow(tags, characterNames, textTheme, colorScheme),
              Expanded(
                child: notes.isEmpty
                    ? _buildEmptyState(colorScheme, textTheme)
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: notes.length,
                  itemBuilder: (context, index) => _buildNoteItem(
                    notes[index],
                    colorScheme,
                    textTheme,
                    isSelected: _selectedNote?.key == notes[index].key,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _selectedNote != null
              ? NoteEditPage(note: _selectedNote!)
              : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.note_outlined,
                  size: 48,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  '${S.of(context).select} ${S.of(context).posts.toLowerCase()}',
                  style: textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
      List<Note> allNotes,
      List<String> tags,
      List<String> characterNames,
      ColorScheme colorScheme,
      TextTheme textTheme,
      ) {
    return Column(
      children: [
        if (tags.isNotEmpty || characterNames.isNotEmpty)
          _buildFiltersRow(tags, characterNames, textTheme, colorScheme),
        Expanded(
          child: _buildNotesList(
            _isSearching || _selectedTag != null || _selectedCharacter != null
                ? _filteredNotes
                : allNotes,
            colorScheme,
            textTheme,
          ),
        ),
      ],
    );
  }
}