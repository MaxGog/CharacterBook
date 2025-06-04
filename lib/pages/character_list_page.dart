import 'dart:typed_data';
import 'package:characterbook/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/character_model.dart';
import 'character_detail_page.dart';
import 'character_edit_page.dart';

class CharacterListPage extends StatefulWidget {
  const CharacterListPage({super.key});

  @override
  State<CharacterListPage> createState() => _CharacterListPageState();
}

class _CharacterListPageState extends State<CharacterListPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Character> _filteredCharacters = [];
  bool _isSearching = false;
  String? _selectedTag;

  List<String> _generateTags(List<Character> characters) {
    final tags = <String>{};

    for (final character in characters) {
      tags.add(character.gender);

      if (character.age < 18) {
        tags.add('Дети');
      } else if (character.age < 30) {
        tags.add('Молодые');
      } else if (character.age < 50) {
        tags.add('Взрослые');
      } else {
        tags.add('Пожилые');
      }

      if (character.name.length <= 4) {
        tags.add('Короткое имя');
      }
    }

    return tags.toList()..sort();
  }

  void _filterCharacters(String query, List<Character> allCharacters) {
    setState(() {
      _filteredCharacters = allCharacters.where((character) {
        final matchesSearch = query.isEmpty ||
            character.name.toLowerCase().contains(query.toLowerCase()) ||
            character.age.toString().contains(query) ||
            character.gender.toLowerCase().contains(query.toLowerCase());

        final matchesTag = _selectedTag == null ||
            (character.gender == _selectedTag) ||
            (_selectedTag == 'Дети' && character.age < 18) ||
            (_selectedTag == 'Молодые' && character.age < 30) ||
            (_selectedTag == 'Взрослые' && character.age < 50) ||
            (_selectedTag == 'Пожилые' && character.age >= 50) ||
            (_selectedTag == 'Короткое имя' && character.name.length <= 4);

        return matchesSearch && matchesTag;
      }).toList();
    });
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
            hintText: 'Поиск персонажей...',
            border: InputBorder.none,
            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          style: Theme.of(context).textTheme.bodyLarge,
          onChanged: (query) {
            final box = Hive.box<Character>('characters');
            final allCharacters = box.values.toList().cast<Character>();
            _filterCharacters(query, allCharacters);
          },
        )
            : Text(
          'Мои персонажи',
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
                  _selectedTag = null;
                  _filteredCharacters = [];
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
      body: ValueListenableBuilder<Box<Character>>(
        valueListenable: Hive.box<Character>('characters').listenable(),
        builder: (context, box, _) {
          final allCharacters = box.values.toList().cast<Character>();
          final tags = _generateTags(allCharacters);

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
                              _filterCharacters(_searchController.text, allCharacters);
                            });
                          },
                          shape: StadiumBorder(
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                          showCheckmark: false,
                          side: BorderSide.none,
                          selectedColor:
                          Theme.of(context).colorScheme.secondaryContainer,
                          labelStyle: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(
                            color: _selectedTag == tag
                                ? Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              Expanded(
                child: _buildCharactersList(
                  _isSearching || _selectedTag != null
                      ? _filteredCharacters
                      : allCharacters,
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
            builder: (context) => const CharacterEditPage(),
          ),
        ),
      ),
    );
  }

  Widget _buildCharactersList(List<Character> characters) {
    if (characters.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search,
              size: 48,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _isSearching && _searchController.text.isNotEmpty
                  ? 'Ничего не найдено'
                  : 'Нет персонажей',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: characters.length,
      itemBuilder: (context, index) {
        final character = characters[index];
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
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CharacterDetailPage(character: character),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  character.imageBytes != null
                      ? CircleAvatar(
                    backgroundImage: MemoryImage(character.imageBytes!),
                    radius: 28,
                  )
                      : CircleAvatar(
                    radius: 28,
                    backgroundColor:
                    Theme.of(context).colorScheme.surfaceVariant,
                    child: Icon(
                      Icons.person,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          character.name,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Text(
                          '${character.age} лет, ${character.gender}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () => _deleteCharacter(context, character),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _deleteCharacter(BuildContext context, Character character) async {
    final confirmed = await _showDeleteConfirmationDialog(context);
    if (confirmed ?? false) {
      final box = Hive.box<Character>('characters');
      await box.delete(character.key);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Персонаж удален'),
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
          title: const Text('Удаление персонажа'),
          content: const Text('Вы уверены, что хотите удалить этого персонажа?'),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Отмена',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text(
                'Удалить',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }
}