import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/character_model.dart';
import '../services/character_qr_service.dart';
import 'character_detail_page.dart';
import 'character_import_page.dart';
import 'character_management_page.dart';
import 'settings_page.dart';

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

      tags.add(switch (character.age) {
        < 18 => 'Дети',
        < 30 => 'Молодые',
        < 50 => 'Взрослые',
        _ => 'Пожилые',
      });

      if (character.name.length <= 4) tags.add('Короткое имя');
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

  Future<void> _importCharacterFromFile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CharacterImportPage()),
    );

    if (result != null && result is Character && mounted) {
      _showSnackBar('Персонаж "${result.name}" успешно импортирован');
    }
  }

  Future<void> _scanCharacterQR() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerScreen()),
    );

    if (result != null && result is Character && mounted) {
      _showSnackBar('Персонаж "${result.name}" успешно импортирован');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: _buildAppBar(theme),
      body: ValueListenableBuilder<Box<Character>>(
        valueListenable: Hive.box<Character>('characters').listenable(),
        builder: (context, box, _) {
          final allCharacters = box.values.toList().cast<Character>();
          final tags = _generateTags(allCharacters);
          final characters = _isSearching || _selectedTag != null
              ? _filteredCharacters
              : allCharacters;

          return Column(
            children: [
              if (tags.isNotEmpty) _buildTagFilter(tags, theme, allCharacters),
              Expanded(child: _buildCharactersList(characters, theme)),
            ],
          );
        },
      ),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  AppBar _buildAppBar(ThemeData theme) {
    return AppBar(
        title: _isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Поиск персонажей...',
            border: InputBorder.none,
            hintStyle: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant),
          ),
          style: theme.textTheme.bodyLarge,
          onChanged: (query) {
            final allCharacters = Hive.box<Character>('characters').values.toList().cast<Character>();
            _filterCharacters(query, allCharacters);
          },
        )
            : Text('Мои персонажи', style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
              onPressed: () => setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchController.clear();
                _selectedTag = null;
                _filteredCharacters = [];
              }
            }),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const SettingsPage())),
          )
        ],
    );
  }

  Widget _buildTagFilter(List<String> tags, ThemeData theme, List<Character> allCharacters) {
    return Container(
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
              onSelected: (selected) => setState(() {
                _selectedTag = selected ? tag : null;
                _filterCharacters(_searchController.text, allCharacters);
              }),
              shape: StadiumBorder(side: BorderSide(color: theme.colorScheme.outline)),
              showCheckmark: false,
              selectedColor: theme.colorScheme.secondaryContainer,
              labelStyle: theme.textTheme.labelLarge?.copyWith(
                  color: _selectedTag == tag
                      ? theme.colorScheme.onSecondaryContainer
                      : theme.colorScheme.onSurface),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCharactersList(List<Character> characters, ThemeData theme) {
    if (characters.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search, size: 48,
              color: theme.colorScheme.onSurface),
            const SizedBox(height: 16),
            Text(
              _isSearching && _searchController.text.isNotEmpty
              ? 'Ничего не найдено'
              : 'Нет персонажей',
              style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface),
            )
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: characters.length,
      itemBuilder: (context, index) => _buildCharacterCard(characters[index], theme),
    );
  }

  Widget _buildCharacterCard(Character character, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
              color: theme.colorScheme.outlineVariant,
              width: 1)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CharacterDetailPage(character: character))),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              character.imageBytes != null
                  ? CircleAvatar(
                  backgroundImage: MemoryImage(character.imageBytes!),
                  radius: 28)
                  : CircleAvatar(
                  radius: 28,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  child: Icon(Icons.person,
                      color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(character.name, style: theme.textTheme.bodyLarge),
                    Text('${character.age} лет, ${character.gender}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface)),
                  ],
                ),
              ),
              IconButton(
                  icon: Icon(Icons.delete,
                      color: theme.colorScheme.onSurfaceVariant),
                  onPressed: () => _deleteCharacter(character)),
            ],
          ),
        ),
      ),
    );
  }

  Column _buildFloatingActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
            heroTag: 'import_btn',
            onPressed: _importCharacterFromFile,
            mini: true,
            tooltip: 'Импорт из файла',
            child: const Icon(Icons.file_upload)),
        const SizedBox(height: 16),
        FloatingActionButton(
            heroTag: 'scan_btn',
            onPressed: _scanCharacterQR,
            mini: true,
            tooltip: 'Сканировать QR-код',
            child: const Icon(Icons.qr_code_scanner)),
        const SizedBox(height: 16),
        FloatingActionButton(
            heroTag: 'add_btn',
            child: const Icon(Icons.add),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CharacterEditPage()))),
      ],
    );
  }

  Future<void> _deleteCharacter(Character character) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удаление персонажа'),
        content: const Text('Вы уверены, что хотите удалить этого персонажа?'),
        actions: [
          TextButton(
              child: Text('Отмена',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
              onPressed: () => Navigator.of(context).pop(false)),
          TextButton(
              child: Text('Удалить',
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
              onPressed: () => Navigator.of(context).pop(true)),
        ],
      ),
    );

    if (confirmed ?? false) {
      await Hive.box<Character>('characters').delete(character.key);
      _showSnackBar('Персонаж удален');
    }
  }
}