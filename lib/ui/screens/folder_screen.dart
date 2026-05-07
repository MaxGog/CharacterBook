import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/ui/widgets/dialogs/folder_dialog.dart';
import 'package:characterbook/ui/screens/characters/character_management_screen.dart';
import 'package:characterbook/ui/screens/notes/note_management_screen.dart';
import 'package:characterbook/ui/screens/races/race_management_screen.dart';
import 'package:characterbook/ui/widgets/states/empty_folders_state.dart';
import 'package:characterbook/ui/widgets/items/character_card_item.dart';
import 'package:characterbook/ui/widgets/items/note_card_item.dart';
import 'package:characterbook/ui/widgets/items/race_card_item.dart';
import 'package:characterbook/ui/widgets/list/list_state_indicator.dart';
import 'package:characterbook/ui/widgets/performance/optimized_value_listenable.dart';
import 'package:flutter/material.dart';
import 'package:characterbook/data/models/folder_model.dart';
import 'package:characterbook/data/models/character_model.dart';
import 'package:characterbook/data/models/race_model.dart';
import 'package:characterbook/data/models/note_model.dart';
import 'package:characterbook/ui/widgets/appbar/common_main_app_bar.dart';
import 'package:characterbook/ui/widgets/buttons/common_fab_menu.dart';
import 'package:characterbook/ui/widgets/tools_context_menu.dart';
import 'package:flutter/rendering.dart';
import 'package:hive_flutter/hive_flutter.dart';

/*class FoldersScreen extends StatefulWidget {
  final FolderType folderType;

  const FoldersScreen({super.key, required this.folderType});

  @override
  State<FoldersScreen> createState() => _FoldersScreenState();
}

class _FoldersScreenState extends State<FoldersScreen> {
  late Box<Folder> _folderBox;
  late Box<Character> _characterBox;
  late Box<Race> _raceBox;
  late Box<Note> _noteBox;
  
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  
  bool isSearching = false;
  bool isFabVisible = true;
  String? errorMessage;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _folderBox = Hive.box<Folder>('folders');
    _characterBox = Hive.box<Character>('characters');
    _raceBox = Hive.box<Race>('races');
    _noteBox = Hive.box<Note>('notes');
    
    searchController.addListener(_onSearchChanged);
    scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    searchController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  String _getTitle(S s) {
    return switch (widget.folderType) {
      FolderType.character => s.characters,
      FolderType.race => s.races,
      FolderType.note => s.posts,
      FolderType.template => s.templates,
    };
  }

  List<Folder> _getFilteredFolders() {
    return _folderBox.values
        .where((folder) => 
          folder.type == widget.folderType &&
          (folder.parentId == null || folder.parentId!.isEmpty) &&
          (_searchQuery.isEmpty || 
           folder.name.toLowerCase().contains(_searchQuery.toLowerCase())))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  List<Widget> _buildFolderContents(Folder folder) {
    switch (folder.type) {
      case FolderType.character:
        return _buildCharacterContents(folder);
      case FolderType.race:
        return _buildRaceContents(folder);
      case FolderType.note:
        return _buildNoteContents(folder);
      case FolderType.template:
        return [];
    }
  }

  List<Widget> _buildCharacterContents(Folder folder) {
    final characters = _characterBox.values
        .where((character) => folder.contentIds.contains(character.key.toString()))
        .toList();

    if (characters.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            S.of(context).characters,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ];
    }

    return characters.map((character) => CharacterCardItem(
      character: character,
      isSelected: false,
      onTap: () => _openCharacter(character),
      onLongPress: () => _showCharacterContextMenu(character),
      onDelete: () => _deleteCharacter(character),
      onEdit: () => { },
    )).toList();
  }

  List<Widget> _buildRaceContents(Folder folder) {
    final races = _raceBox.values
        .where((race) => folder.contentIds.contains(race.key.toString()))
        .toList();

    if (races.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            S.of(context).races,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ];
    }

    return races.map((race) => RaceCardItem(
      race: race,
      onTap: () => _openRace(race),
      onLongPress: () => _showRaceContextMenu(race),
    )).toList();
  }

  List<Widget> _buildNoteContents(Folder folder) {
    final notes = _noteBox.values
        .where((note) => folder.contentIds.contains(note.id))
        .toList();

    if (notes.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            S.of(context).posts,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ];
    }

    return notes.map((note) => NoteCardItem(
      note: note,
      onTap: () => _openNote(note),
      onEdit: () => _editNote(note),
      onDelete: () => _deleteNote(note),
    )).toList();
  }

  void _toggleSearch() {
    setState(() {
      isSearching = !isSearching;
      if (!isSearching) {
        searchController.clear();
        _searchQuery = '';
      }
    });
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = searchController.text;
    });
  }

  void _onScroll() {
    final isScrollingDown = scrollController.position.userScrollDirection == 
        ScrollDirection.reverse;
    if (isScrollingDown && isFabVisible) {
      setState(() => isFabVisible = false);
    } else if (!isScrollingDown && !isFabVisible) {
      setState(() => isFabVisible = true);
    }
  }

  void _createNewFolder() {
    _showFolderDialog(null, null);
  }

  void _showFolderDialog(Folder? folder, Folder? parentFolder) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28))
      ),
      builder: (context) => FolderDialog(
        folder: folder,
        parentFolder: parentFolder,
        folderType: widget.folderType,
        onSave: _saveFolder,
      ),
    );
  }

  Future<void> _saveFolder(Folder? folder, String name, Folder? parentFolder, int colorValue) async {
    if (folder == null) {
      final newFolder = Folder(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        type: widget.folderType,
        parentId: parentFolder?.id,
        colorValue: colorValue,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _folderBox.put(newFolder.id, newFolder);
    } else {
      folder.name = name;
      folder.colorValue = colorValue;
      folder.updatedAt = DateTime.now();
      await folder.save();
    }
  }

  void _deleteFolder(Folder folder) {
    final s = S.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          s.delete,
          style: TextStyle(color: colorScheme.onSurface),
        ),
        content: Text(
          s.delete,
          style: TextStyle(color: colorScheme.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              s.cancel,
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
          TextButton(
            onPressed: () async {
              await folder.delete();
              if (mounted) Navigator.pop(context);
            },
            child: Text(
              s.delete,
              style: TextStyle(color: colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _openCharacter(Character character) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CharacterManagementScreen(character: character),
      ),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  void _showCharacterContextMenu(Character character) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28))
      ),
      builder: (context) => ContextMenu(
        item: character,
        onEdit: () => _openCharacter(character),
        onDelete: () => _deleteCharacter(character),
        showExportPdf: true,
        showCopy: true,
        showShare: true,
      ),
    );
  }

  Future<void> _deleteCharacter(Character character) async {
    final confirmed = await _showDeleteConfirmationDialog(
      S.of(context).delete,
      S.of(context).character_delete_confirm,
    );

    if (confirmed) {
      await character.delete();
      if (mounted) {
        _showSnackBar(S.of(context).character_deleted);
      }
    }
  }

  void _openRace(Race race) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RaceManagementScreen(race: race),
      ),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  void _showRaceContextMenu(Race race) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28))
      ),
      builder: (context) => ContextMenu(
        item: race,
        onEdit: () => _openRace(race),
        onDelete: () => _deleteRace(race),
        showExportPdf: false,
        showCopy: false,
        showShare: false,
      ),
    );
  }

  Future<void> _deleteRace(Race race) async {
    final isUsed = await _isRaceUsed(race);
    if (isUsed) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(S.of(context).race_delete_error_title),
            content: Text(S.of(context).race_delete_error_content),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(S.of(context).ok),
              ),
            ],
          ),
        );
      }
      return;
    }

    final confirmed = await _showDeleteConfirmationDialog(
      S.of(context).delete,
      S.of(context).race_delete_confirm,
    );

    if (confirmed) {
      await race.delete();
      if (mounted) {
        _showSnackBar(S.of(context).race_deleted);
      }
    }
  }

  Future<bool> _isRaceUsed(Race race) async {
    final characters = _characterBox.values;
    return characters.any((character) => character.race?.key == race.key);
  }

  void _openNote(Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteManagementScreen(note: note),
      ),
    );
  }

  void _editNote(Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteManagementScreen(note: note),
      ),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _deleteNote(Note note) async {
    final confirmed = await _showDeleteConfirmationDialog(
      S.of(context).delete,
      '${S.of(context).posts} "${note.title}" ${S.of(context).template_delete_confirm}',
    );

    if (confirmed) {
      await note.delete();
      if (mounted) {
        _showSnackBar(
          '${S.of(context).posts} "${note.title}" ${S.of(context).template_deleted}',
          action: SnackBarAction(
            label: S.of(context).cancel,
            onPressed: () => _noteBox.add(note),
          ),
        );
      }
    }
  }

  Future<bool> _showDeleteConfirmationDialog(String title, String content) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(S.of(context).cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              S.of(context).delete,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showSnackBar(String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: action,
      ),
    );
  }

  void _editFolder(Folder folder) {
    _showFolderDialog(folder, null);
  }

  Widget _buildFolderItem(BuildContext context, Folder folder) {
    return FolderItem(
      folder: folder,
      onEdit: () => _editFolder(folder),
      onDelete: () => _deleteFolder(folder),
      children: _buildFolderContents(folder),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Scaffold(
      appBar: CommonMainAppBar(
        title: _getTitle(s),
        isSearching: isSearching,
        searchController: searchController,
        searchHint: s.search_hint,
        onSearchToggle: _toggleSearch,
      ),
      body: Column(
        children: [
          ListStateIndicator(
            isLoading: false,
            errorMessage: errorMessage,
            onErrorClose: () => setState(() => errorMessage = null),
          ),
          Expanded(
            child: OptimizedValueListenable<Folder>(
              box: _folderBox,
              listen: true,
              builder: (context, allFolders) {
                final folders = _getFilteredFolders();
                
                if (folders.isEmpty) {
                  return EmptyFoldersState(
                    folderType: widget.folderType,
                    onCreate: _createNewFolder,
                  );
                }

                return ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.only(bottom: 88),
                  itemCount: folders.length,
                  itemBuilder: (context, index) => _buildFolderItem(context, folders[index]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: isFabVisible 
          ? CommonListFloatingButtons(
              onAdd: _createNewFolder,
              addTooltip: s.create,
              heroTag: "folder_list",
            )
          : null,
    );
  }
}*/