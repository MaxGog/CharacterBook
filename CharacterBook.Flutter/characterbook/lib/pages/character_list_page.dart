import 'dart:typed_data';
import 'package:flutter/material.dart';
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCharacters(String query, List<Character> allCharacters) {
    setState(() {
      _filteredCharacters = allCharacters.where((character) {
        final nameLower = character.name.toLowerCase();
        final ageLower = character.age.toString().toLowerCase();
        final genderLower = character.gender.toLowerCase();
        final searchLower = query.toLowerCase();

        return nameLower.contains(searchLower) ||
            ageLower.contains(searchLower) ||
            genderLower.contains(searchLower);
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
            hintStyle: TextStyle(color: Colors.black),
          ),
          style: const TextStyle(color: Colors.black),
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
          final charactersToDisplay =
          _isSearching && _searchController.text.isNotEmpty
              ? _filteredCharacters
              : allCharacters;

          if (charactersToDisplay.isEmpty) {
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
            itemCount: charactersToDisplay.length,
            itemBuilder: (context, index) {
              final character = charactersToDisplay[index];
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

  void _deleteCharacter(BuildContext context, Character character) async {
    final box = Hive.box<Character>('characters');
    await box.delete(character.key);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Персонаж удален')),
    );
  }
}