import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/character_model.dart';
import '../models/race_model.dart';
import 'race_management_page.dart';

class RaceListPage extends StatefulWidget {
  const RaceListPage({super.key});

  @override
  State<RaceListPage> createState() => _RaceListPageState();
}

class _RaceListPageState extends State<RaceListPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Race> _filteredRaces = [];
  bool _isSearching = false;

  void _filterRaces(String query, List<Race> allRaces) {
    setState(() {
      _filteredRaces = allRaces.where((race) {
        return query.isEmpty ||
            race.name.toLowerCase().contains(query.toLowerCase()) ||
            race.description.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<bool> _isRaceUsed(Race race) async {
    final charactersBox = Hive.box<Character>('characters');
    final characters = charactersBox.values.toList();

    return characters.any((character) => character.race?.key == race.key);
  }

  Future<void> _deleteRace(BuildContext context, Race race) async {
    final isUsed = await _isRaceUsed(race);

    if (isUsed) {
      _showRaceInUseDialog(context);
      return;
    }

    final confirmed = await _showDeleteConfirmationDialog(context);
    if (confirmed ?? false) {
      final box = Hive.box<Race>('races');
      await box.delete(race.key);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Раса удалена'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Удаление расы'),
          content: const Text('Вы уверены, что хотите удалить эту расу?'),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Отмена',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text(
                'Удалить',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
  }

  void _showRaceInUseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Невозможно удалить расу'),
          content: const Text('Эта раса используется одним или несколькими персонажами. '
              'Сначала измените расу этих персонажей.'),
          actions: <Widget>[
            TextButton(
              child: Text(
                'OK',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Поиск рас...',
            border: InputBorder.none,
            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          style: Theme.of(context).textTheme.bodyLarge,
          onChanged: (query) {
            final box = Hive.box<Race>('races');
            final allRaces = box.values.toList().cast<Race>();
            _filterRaces(query, allRaces);
          },
        )
            : Text(
          'Расы',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
                  _filteredRaces = [];
                }
              });
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<Box<Race>>(
        valueListenable: Hive.box<Race>('races').listenable(),
        builder: (context, box, _) {
          final allRaces = box.values.toList().cast<Race>();

          return Column(
            children: [
              Expanded(
                child: _buildRacesList(
                  _isSearching ? _filteredRaces : allRaces,
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RaceManagementPage(),
            ),
          );
          if (result == true) {
            final box = Hive.box<Race>('races');
            final allRaces = box.values.toList().cast<Race>();
            _filterRaces(_searchController.text, allRaces);
          }
        },
      ),
    );
  }

  Widget _buildRacesList(List<Race> races) {
    if (races.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_people,
              size: 48,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _isSearching && _searchController.text.isNotEmpty
                  ? 'Ничего не найдено'
                  : 'Нет созданных рас',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color:
                Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: races.length,
      itemBuilder: (context, index) {
        final race = races[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
              width: 1,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RaceManagementPage(race: race),
                ),
              );
              if (result == true) {
                final box = Hive.box<Race>('races');
                final allRaces = box.values.toList().cast<Race>();
                _filterRaces(_searchController.text, allRaces);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  race.logo != null
                      ? CircleAvatar(
                    backgroundImage: MemoryImage(race.logo!),
                    radius: 28,
                  )
                      : CircleAvatar(
                    radius: 28,
                    backgroundColor:
                    Theme.of(context).colorScheme.surfaceVariant,
                    child: Icon(
                      Icons.emoji_people,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          race.name,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Text(
                          race.description.isNotEmpty
                              ? race.description
                              : 'Нет описания',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () => _deleteRace(context, race),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}