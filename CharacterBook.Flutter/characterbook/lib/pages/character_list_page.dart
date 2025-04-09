import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/character_model.dart';
import 'character_detail_page.dart';
import 'character_edit_page.dart';

class CharacterListPage extends StatelessWidget {
  const CharacterListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои персонажи'),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<Box<Character>>(
        valueListenable: Hive.box<Character>('characters').listenable(),
        builder: (context, box, _) {
          final characters = box.values.toList().cast<Character>();

          if (characters.isEmpty) {
            return const Center(
              child: Text(
                'Нет персонажей',
                style: TextStyle(fontSize: 18),
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
