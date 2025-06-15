import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'package:characterbook/models/character_model.dart';
import 'package:characterbook/models/note_model.dart';
import 'package:characterbook/models/race_model.dart';
import 'package:characterbook/models/template_model.dart';

import 'characters/character_management_page.dart';
import 'notes/note_management_page.dart';
import 'races/race_management_page.dart';
import 'templates/template_edit_page.dart';
import 'settings_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  late final List<Character> _characters;
  late final List<Race> _races;
  late final List<Note> _notes;
  late final List<QuestionnaireTemplate> _templates;
  late List<dynamic> _filteredResults;
  bool _isLoading = true;
  late final FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode();
    _searchController.addListener(_onSearchChanged);
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final characterBox = await Hive.openBox<Character>('characters');
      final raceBox = await Hive.openBox<Race>('races');
      final noteBox = await Hive.openBox<Note>('notes');
      final templateBox = await Hive.openBox<QuestionnaireTemplate>('templates');

      if (mounted) {
        setState(() {
          _characters = characterBox.values.toList();
          _races = raceBox.values.toList();
          _notes = noteBox.values.toList();
          _templates = templateBox.values.toList();
          _filteredResults = [..._characters, ..._races, ..._notes, ..._templates];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredResults = [..._characters, ..._races, ..._notes, ..._templates];
      } else {
        _filteredResults = [
          ..._filterCharacters(query),
          ..._filterRaces(query),
          ..._filterNotes(query),
          ..._filterTemplates(query),
        ];
      }
    });
  }

  List<Character> _filterCharacters(String query) {
    return _characters.where((character) {
      return character.name.toLowerCase().contains(query) ||
          character.biography.toLowerCase().contains(query) ||
          character.personality.toLowerCase().contains(query) ||
          character.appearance.toLowerCase().contains(query) ||
          character.abilities.toLowerCase().contains(query) ||
          character.other.toLowerCase().contains(query) ||
          (character.race?.name.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  List<Race> _filterRaces(String query) {
    return _races.where((race) {
      return race.name.toLowerCase().contains(query) ||
          race.description.toLowerCase().contains(query) ||
          race.biology.toLowerCase().contains(query) ||
          race.backstory.toLowerCase().contains(query);
    }).toList();
  }

  List<Note> _filterNotes(String query) {
    return _notes.where((note) {
      return note.title.toLowerCase().contains(query) ||
          note.content.toLowerCase().contains(query) ||
          note.tags.any((tag) => tag.toLowerCase().contains(query));
    }).toList();
  }

  List<QuestionnaireTemplate> _filterTemplates(String query) {
    return _templates.where((template) {
      return template.name.toLowerCase().contains(query) ||
          template.standardFields.any((field) => field.toLowerCase().contains(query)) ||
          template.customFields.any((field) =>
          field.key.toLowerCase().contains(query) ||
              field.value.toLowerCase().contains(query));
    }).toList();
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: SearchBar(
          focusNode: _searchFocusNode,
          controller: _searchController,
          hintText: 'Поиск по персонажам, расам, заметкам и шаблонам...',
          leading: const Icon(Icons.search),
          elevation: const WidgetStatePropertyAll(1.0),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 16.0),
          ),
          backgroundColor: WidgetStatePropertyAll(
            colorScheme.surfaceContainerLow,
          ),
          surfaceTintColor: WidgetStatePropertyAll(colorScheme.surfaceTint),
          onTap: () => _searchFocusNode.requestFocus(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: CustomScrollView(
          slivers: [
            if (_isLoading)
              SliverFillRemaining(
                child: Center(
                    child: CircularProgressIndicator(
                      color: colorScheme.primary,
                    )),
              )
            else if (_filteredResults.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _searchController.text.isEmpty
                            ? Icons.search_off
                            : Icons.no_sim_outlined,
                        size: 48,
                        color: colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchController.text.isEmpty
                            ? 'Данные не найдены'
                            : 'Ничего не найдено по запросу',
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            '"${_searchController.text}"',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.outline,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                sliver: SliverList.separated(
                  itemCount: _filteredResults.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = _filteredResults[index];
                    return _SearchResultItem(
                      item: item,
                      onTap: () async {
                        final result = await _navigateToEditPage(item);
                        if (result == true) await _refreshData();
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _navigateToEditPage(dynamic item) async {
    if (item is Character) {
      return await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CharacterEditPage(character: item),
        ),
      );
    } else if (item is Race) {
      return await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RaceManagementPage(race: item),
        ),
      );
    } else if (item is Note) {
      return await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NoteEditPage(note: item),
        ),
      );
    } else if (item is QuestionnaireTemplate) {
      return await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TemplateEditPage(template: item),
        ),
      );
    }
    return null;
  }
}

class _SearchResultItem extends StatelessWidget {
  final dynamic item;
  final VoidCallback onTap;

  const _SearchResultItem({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final isCharacter = item is Character;
    final isRace = item is Race;
    final isNote = item is Note;
    final isTemplate = item is QuestionnaireTemplate;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        color: colorScheme.surfaceContainerLow,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                _buildLeadingIcon(context),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCharacter
                            ? item.name
                            : isRace
                            ? item.name
                            : isNote
                            ? item.title
                            : item.name,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isCharacter
                            ? item.race?.name ?? 'Без расы'
                            : isRace
                            ? item.description.isNotEmpty
                            ? item.description
                            : 'Описание отсутствует'
                            : isNote
                            ? item.content.isNotEmpty
                            ? item.content
                            : 'Содержание отсутствует'
                            : '${item.standardFields.length + item.customFields.length} полей',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: colorScheme.outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingIcon(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (item is Character) {
      return item.imageBytes != null
          ? CircleAvatar(
        backgroundImage: MemoryImage(item.imageBytes!),
      )
          : CircleAvatar(
        backgroundColor: colorScheme.surfaceContainerHigh,
        child: Icon(
          Icons.person_outline,
          color: colorScheme.primary,
        ),
      );
    } else if (item is Race) {
      return item.logo != null
          ? CircleAvatar(
        backgroundImage: MemoryImage(item.logo!),
      )
          : CircleAvatar(
        backgroundColor: colorScheme.surfaceContainerHigh,
        child: Icon(
          Icons.emoji_people_outlined,
          color: colorScheme.primary,
        ),
      );
    } else if (item is Note) {
      return CircleAvatar(
        backgroundColor: colorScheme.surfaceContainerHigh,
        child: Icon(
          Icons.note_outlined,
          color: colorScheme.primary,
        ),
      );
    } else {
      return CircleAvatar(
        backgroundColor: colorScheme.surfaceContainerHigh,
        child: Icon(
          Icons.library_books_outlined,
          color: colorScheme.primary,
        ),
      );
    }
  }
}