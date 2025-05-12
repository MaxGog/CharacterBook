import 'dart:typed_data';
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
          decoration: const InputDecoration(
            hintText: 'Поиск персонажей...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: (query) {
            final box = Hive.box<Character>('characters');
            final allCharacters = box.values.toList().cast<Character>();
            _filterCharacters(query, allCharacters);
          },
        )
            : const Text('Мои персонажи'),
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
                SizedBox(
                  height: 50,
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
        child: Text(
          _isSearching && _searchController.text.isNotEmpty
              ? 'Ничего не найдено'
              : 'Нет персонажей',
          style: const TextStyle(fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      itemCount: characters.length,
      itemBuilder: (context, index) {
        final character = characters[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            leading: character.imageBytes != null
                ? CircleAvatar(
              backgroundImage: MemoryImage(character.imageBytes!),
              radius: 25,
            )
                : const CircleAvatar(
              radius: 25,
              child: Icon(Icons.person),
            ),
            title: Text(character.name),
            subtitle: Text('${character.age} лет, ${character.gender}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteCharacter(context, character),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CharacterDetailPage(character: character),
              ),
            ),
          ),
        );
      },
    );
  }

  void _deleteCharacter(BuildContext context, Character character) async {
    final box = Hive.box<Character>('characters');
    await box.delete(character.key);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Персонаж удален')),
    );
  }
}