import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/character_model.dart';
import '../services/clipboard_service.dart';
import '../services/character_export_service.dart';
import '../services/file_picker_service.dart';
import 'character_detail_page.dart';
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
  bool _isImporting = false;
  String? _selectedTag;
  String? _errorMessage;
  int? _draggedItemIndex;
  Character? _selectedCharacter;
  final FilePickerService _filePickerService = FilePickerService();

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

    final sortTags = [
      'А-Я',
      'Я-А',
      'Возраст ↑',
      'Возраст ↓',
    ];

    return [...tags.toList()..sort(), ...sortTags];
  }

  void _filterCharacters(String query, List<Character> allCharacters) {
    setState(() {
      List<Character> filtered = allCharacters.where((character) {
        final matchesSearch = query.isEmpty ||
            character.name.toLowerCase().contains(query.toLowerCase()) ||
            character.age.toString().contains(query) ||
            character.gender.toLowerCase().contains(query.toLowerCase());

        final matchesTag = _selectedTag == null ||
            _selectedTag == 'А-Я' ||
            _selectedTag == 'Я-А' ||
            _selectedTag == 'Возраст ↑' ||
            _selectedTag == 'Возраст ↓' ||
            (character.gender == _selectedTag) ||
            (_selectedTag == 'Дети' && character.age < 18) ||
            (_selectedTag == 'Молодые' && character.age < 30) ||
            (_selectedTag == 'Взрослые' && character.age < 50) ||
            (_selectedTag == 'Пожилые' && character.age >= 50) ||
            (_selectedTag == 'Короткое имя' && character.name.length <= 4);

        return matchesSearch && matchesTag;
      }).toList();

      if (_selectedTag == 'А-Я') {
        filtered.sort((a, b) => a.name.compareTo(b.name));
      } else if (_selectedTag == 'Я-А') {
        filtered.sort((a, b) => b.name.compareTo(a.name));
      } else if (_selectedTag == 'Возраст ↑') {
        filtered.sort((a, b) => a.age.compareTo(b.age));
      } else if (_selectedTag == 'Возраст ↓') {
        filtered.sort((a, b) => b.age.compareTo(a.age));
      }

      _filteredCharacters = filtered;

      if (_selectedCharacter != null && !filtered.contains(_selectedCharacter)) {
        _selectedCharacter = null;
      }
    });
  }

  Future<void> _importCharacter() async {
    try {
      setState(() {
        _isImporting = true;
        _errorMessage = null;
      });

      final character = await _filePickerService.importCharacter();
      if (character == null) return;

      final box = Hive.box<Character>('characters');
      await box.add(character);

      _showSnackBar('Персонаж "${character.name}" успешно импортирован');
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isImporting = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showCharacterContextMenu(Character character, BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit, color: theme.colorScheme.onSurface),
              title: Text('Редактировать', style: theme.textTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                _editCharacter(character);
              },
            ),
            Divider(height: 1, color: theme.colorScheme.surfaceContainerHighest),
            ListTile(
              leading: Icon(Icons.copy, color: theme.colorScheme.onSurface),
              title: Text('Копировать данные', style: theme.textTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                _copyCharacterToClipboard(character);
              },
            ),
            Divider(height: 1, color: theme.colorScheme.surfaceContainerHighest),
            ListTile(
              leading: Icon(Icons.picture_as_pdf, color: theme.colorScheme.onSurface),
              title: Text('Экспорт в PDF', style: theme.textTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                _exportToPdf(character);
              },
            ),
            Divider(height: 1, color: theme.colorScheme.surfaceContainerHighest),
            ListTile(
              leading: Icon(Icons.share, color: theme.colorScheme.onSurface),
              title: Text('Поделиться файлом', style: theme.textTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                _shareCharacterAsFile(character);
              },
            ),
            Divider(height: 1, color: theme.colorScheme.surfaceContainerHighest),
            ListTile(
              leading: Icon(Icons.delete, color: theme.colorScheme.error),
              title: Text('Удалить', style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.error,
              )),
              onTap: () {
                Navigator.pop(context);
                _deleteCharacter(character);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _editCharacter(Character character) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CharacterEditPage(character: character),
      ),
    );
    if (result == true && mounted) {
      _filterCharacters(_searchController.text, Hive.box<Character>('characters').values.toList().cast<Character>());
    }
  }

  Future<void> _copyCharacterToClipboard(Character character) async {
    try {
      await ClipboardService.copyCharacterToClipboard(
        name: character.name,
        age: character.age,
        gender: character.gender,
        raceName: character.race?.name,
        biography: character.biography,
        appearance: character.appearance,
        personality: character.personality,
        abilities: character.abilities,
        other: character.other,
        customFields: character.customFields.map((f) => {'key': f.key, 'value': f.value}).toList(),
      );
      if (mounted) _showSnackBar('Данные персонажа скопированы');
    } catch (e) {
      if (mounted) _showSnackBar('Ошибка копирования: ${e.toString()}');
    }
  }

  Future<void> _exportToPdf(Character character) async {
    try {
      setState(() => _isImporting = true);
      await CharacterExportService(character).exportToPdf();
      if (mounted) _showSnackBar('PDF успешно экспортирован');
    } catch (e) {
      if (mounted) _showSnackBar('Ошибка экспорта в PDF: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  Future<void> _shareCharacterAsFile(Character character) async {
    try {
      setState(() => _isImporting = true);
      await CharacterExportService(character).exportToJson();
    } catch (e) {
      if (mounted) _showSnackBar('Ошибка: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  Future<void> _reorderCharacters(int oldIndex, int newIndex) async {
    if (oldIndex == newIndex) return;

    final box = Hive.box<Character>('characters');
    final characters = box.values.toList().cast<Character>();

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final character = characters.removeAt(oldIndex);
    characters.insert(newIndex, character);

    await box.clear();
    await box.addAll(characters);

    if (mounted) {
      setState(() {
        _filterCharacters(_searchController.text, characters);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWideScreen = MediaQuery.of(context).size.width > 1000;

    return Scaffold(
      appBar: _buildAppBar(theme),
      body: Column(
        children: [
          if (_isImporting) const LinearProgressIndicator(),
          if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: theme.colorScheme.errorContainer,
              child: Row(
                children: [
                  Icon(Icons.error, color: theme.colorScheme.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: theme.colorScheme.onErrorContainer),
                    onPressed: () => setState(() => _errorMessage = null),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ValueListenableBuilder<Box<Character>>(
              valueListenable: Hive.box<Character>('characters').listenable(),
              builder: (context, box, _) {
                final allCharacters = box.values.toList().cast<Character>();
                final tags = _generateTags(allCharacters);
                final characters = _isSearching || _selectedTag != null
                    ? _filteredCharacters
                    : allCharacters;

                return isWideScreen
                    ? _buildWideLayout(characters, tags, theme, allCharacters)
                    : _buildMobileLayout(characters, tags, theme, allCharacters);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  Widget _buildWideLayout(List<Character> characters, List<String> tags, ThemeData theme, List<Character> allCharacters) {
    return Row(
      children: [
      Container(
        width: 400,
        decoration: BoxDecoration(
        border: Border(right: BorderSide(color: theme.dividerColor))),
        child: Column(
          children: [
            if (tags.isNotEmpty) _buildTagFilter(tags, theme, allCharacters),
            Expanded(child: _buildCharactersList(characters, theme)),
          ],
        ),
      ),
      Expanded(
        child: _selectedCharacter != null
            ? CharacterDetailPage(character: _selectedCharacter!)
            : Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_outline,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'Выберите персонажа',
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
      ],
    );
  }

  Widget _buildMobileLayout(List<Character> characters, List<String> tags, ThemeData theme, List<Character> allCharacters) {
    return Column(
      children: [
        if (tags.isNotEmpty) _buildTagFilter(tags, theme, allCharacters),
        Expanded(child: _buildCharactersList(characters, theme)),
      ],
    );
  }

  Widget _buildCharacterCard(Character character, ThemeData theme) {
    final isSelected = _selectedCharacter?.key == character.key;

    return Card(
      key: ValueKey(character.key),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      elevation: 0,
      color: isSelected
          ? theme.colorScheme.secondaryContainer
          : theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? theme.colorScheme.secondary
              : theme.colorScheme.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (MediaQuery.of(context).size.width > 1000) {
            setState(() => _selectedCharacter = character);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CharacterDetailPage(character: character),
              ),
            );
          }
        },
        onLongPress: () => _showCharacterContextMenu(character, context),
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
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.person,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(character.name, style: theme.textTheme.bodyLarge),
                    Text(
                      '${character.age} лет, ${character.gender}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.more_vert, color: theme.colorScheme.onSurfaceVariant),
                onPressed: () => _showCharacterContextMenu(character, context),
              ),
            ],
          ),
        ),
      ),
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
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        style: theme.textTheme.bodyLarge,
        onChanged: (query) {
          final allCharacters = Hive.box<Character>('characters').values.toList().cast<Character>();
          _filterCharacters(query, allCharacters);
        },
      )
          : Text(
        'Мои персонажи',
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
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
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage())),
        ),
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
                    : theme.colorScheme.onSurface,
              ),
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
            Icon(
              Icons.person_search,
              size: 48,
              color: theme.colorScheme.onSurface,
            ),
            const SizedBox(height: 16),
            Text(
              _isSearching && _searchController.text.isNotEmpty
                  ? 'Ничего не найдено'
                  : 'Нет персонажей',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            if (!_isSearching)
              TextButton(
                onPressed: _importCharacter,
                child: const Text('Импортировать персонажа'),
              ),
          ],
        ),
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: characters.length,
      itemBuilder: (context, index) => _buildCharacterCard(characters[index], theme),
      onReorder: (oldIndex, newIndex) async {
        await _reorderCharacters(oldIndex, newIndex);
      },
      buildDefaultDragHandles: false,
      proxyDecorator: (child, index, animation) {
        return Material(
          elevation: 6,
          color: Colors.transparent,
          child: child,
        );
      },
    );
  }

  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: 'import_btn',
          onPressed: _importCharacter,
          mini: true,
          tooltip: 'Импорт из файла',
          child: const Icon(Icons.download),
        ),
        const SizedBox(height: 16),
        FloatingActionButton(
          heroTag: 'add_btn',
          child: const Icon(Icons.add),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CharacterEditPage(),
            ),
          ),
        ),
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
            child: Text(
              'Отмена',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text(
              'Удалить',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await Hive.box<Character>('characters').delete(character.key);
      if (mounted) _showSnackBar('Персонаж удален');
    }
  }
}