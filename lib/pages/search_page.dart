import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'package:characterbook/models/character_model.dart';
import 'package:characterbook/models/note_model.dart';
import 'package:characterbook/models/race_model.dart';

import 'character_management_page.dart';
import 'note_management_page.dart';
import 'race_management_page.dart';
import 'settings_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Character> _characters = [];
  List<Race> _races = [];
  List<Note> _notes = [];
  List<dynamic> _filteredResults = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final characterBox = await Hive.openBox<Character>('characters');
    final raceBox = await Hive.openBox<Race>('races');
    final noteBox = await Hive.openBox<Note>('notes');

    setState(() {
      _characters = characterBox.values.toList();
      _races = raceBox.values.toList();
      _notes = noteBox.values.toList();
      _filteredResults = [..._characters, ..._races, ..._notes];
      _isLoading = false;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredResults = [..._characters, ..._races, ..._notes];
      } else {
        _filteredResults = [];

        // Filter characters
        _filteredResults.addAll(_characters.where((character) {
          return character.name.toLowerCase().contains(query) ||
              character.biography.toLowerCase().contains(query) ||
              character.personality.toLowerCase().contains(query) ||
              character.appearance.toLowerCase().contains(query) ||
              character.abilities.toLowerCase().contains(query) ||
              character.other.toLowerCase().contains(query) ||
              (character.race?.name.toLowerCase().contains(query) ?? false);
        }));

        // Filter races
        _filteredResults.addAll(_races.where((race) {
          return race.name.toLowerCase().contains(query) ||
              race.description.toLowerCase().contains(query) ||
              race.biology.toLowerCase().contains(query) ||
              race.backstory.toLowerCase().contains(query);
        }));

        // Filter notes
        _filteredResults.addAll(_notes.where((note) {
          return note.title.toLowerCase().contains(query) ||
              note.content.toLowerCase().contains(query) ||
              note.tags.any((tag) => tag.toLowerCase().contains(query));
        }));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: SearchBar(
          controller: _searchController,
          hintText: 'Поиск по всему приложению...',
          leading: const Icon(Icons.search),
          elevation: WidgetStateProperty.all(0),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 8.0),
          ),
          surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
          backgroundColor: WidgetStateProperty.all(
            colorScheme.surfaceContainerHighest,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
        scrolledUnderElevation: 4.0,
      ),
      body: CustomScrollView(
        slivers: [
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_filteredResults.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 48, color: colorScheme.outline),
                    const SizedBox(height: 16),
                    Text(
                      _searchController.text.isEmpty
                          ? 'Нет ничего :('
                          : 'Нет результата по запросу "${_searchController.text}"',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final item = _filteredResults[index];
                  final isCharacter = item is Character;
                  final isRace = item is Race;
                  final isNote = item is Note;

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 4.0,
                    ),
                    shadowColor: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12.0),
                      onTap: () async {
                        dynamic result;
                        if (isCharacter) {
                          result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CharacterEditPage(character: item),
                            ),
                          );
                        } else if (isRace) {
                          result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RaceManagementPage(race: item),
                            ),
                          );
                        } else if (isNote) {
                          result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NoteEditPage(note: item),
                            ),
                          );
                        }

                        if (result == true) {
                          await _loadData();
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            _buildLeadingIcon(item),
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
                                        : item.title,
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isCharacter
                                        ? item.race?.name ?? 'Нет расы'
                                        : isRace
                                        ? item.description.isNotEmpty
                                        ? item.description
                                        : 'Нет описания'
                                        : item.content.isNotEmpty
                                        ? item.content
                                        : 'Нет контента',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurface,
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
                  );
                },
                childCount: _filteredResults.length,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLeadingIcon(dynamic item) {
    if (item is Character) {
      return item.imageBytes != null
          ? CircleAvatar(
        backgroundImage: MemoryImage(item.imageBytes!),
      )
          : CircleAvatar(
        child: Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
      );
    } else if (item is Race) {
      return item.logo != null
          ? CircleAvatar(
        backgroundImage: MemoryImage(item.logo!),
      )
          : CircleAvatar(
        child: Icon(Icons.emoji_people,
            color: Theme.of(context).colorScheme.primary),
      );
    } else {
      return CircleAvatar(
        child: Icon(Icons.note, color: Theme.of(context).colorScheme.primary),
      );
    }
  }
}