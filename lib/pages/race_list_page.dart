import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/character_model.dart';
import '../models/race_model.dart';

import '../services/clipboard_service.dart';
import '../services/file_picker_service.dart';

import '../widgets/context_menu.dart';
import '../widgets/custom_floating_buttons.dart';

import 'race_management_page.dart';
import 'settings_page.dart';

class RaceListPage extends StatefulWidget {
  const RaceListPage({super.key});

  @override
  State<RaceListPage> createState() => _RaceListPageState();
}

class _RaceListPageState extends State<RaceListPage> {
  final TextEditingController _searchController = TextEditingController();
  final FilePickerService _filePickerService = FilePickerService();
  List<Race> _filteredRaces = [];
  bool _isSearching = false;
  String? _selectedTag;
  bool _isImporting = false;
  String? _errorMessage;
  Race? _selectedRace;

  List<String> _generateTags(List<Race> races) {
    final tags = <String>{};
    return tags.toList()..sort();
  }

  void _filterRaces(String query, List<Race> allRaces) {
    setState(() {
      _filteredRaces = allRaces.where((race) {
        final matchesSearch = query.isEmpty ||
            race.name.toLowerCase().contains(query.toLowerCase()) ||
            race.description.toLowerCase().contains(query.toLowerCase());

        final matchesTag = _selectedTag == null;

        return matchesSearch && matchesTag;
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<bool> _isRaceUsed(Race race) async {
    final characters = Hive.box<Character>('characters').values;
    return characters.any((character) => character.race?.key == race.key);
  }

  Future<void> _deleteRace(Race race) async {
    if (await _isRaceUsed(race)) {
      if (mounted) _showRaceInUseDialog();
      return;
    }

    final confirmed = await _showDeleteConfirmationDialog();
    if (confirmed ?? false) {
      await Hive.box<Race>('races').delete(race.key);
      if (mounted) _showSnackBar('Раса удалена');
    }
  }

  Future<void> _importRaceFromFile() async {
    try {
      setState(() {
        _isImporting = true;
        _errorMessage = null;
      });

      final race = await _filePickerService.importRace();
      if (race == null) return;

      final box = Hive.box<Race>('races');
      await box.add(race);

      _showSnackBar('Раса "${race.name}" успешно импортирована');
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

  Future<bool?> _showDeleteConfirmationDialog() async {
    if (!mounted) return false;

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удаление расы'),
        content: const Text('Вы уверены, что хотите удалить эту расу?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Отмена',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Удалить',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showRaceInUseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Невозможно удалить расу'),
        content: const Text('Эта раса используется персонажами. Сначала измените их расу.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _copyRaceToClipboard(Race race) async {
    await ClipboardService.copyRaceToClipboard(
      name: race.name,
      description: race.description,
      biology: race.biology,
      backstory: race.backstory,
    );
    if (mounted) _showSnackBar('Раса скопирована в буфер');
  }

  Future<void> _shareRaceAsFile(Race race) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/${race.name}.race');
      await file.writeAsString(jsonEncode(race.toJson()));
      await Share.shareXFiles([XFile(file.path)], text: 'Файл расы ${race.name}');
    } catch (e) {
      if (mounted) _showSnackBar('Ошибка: ${e.toString()}');
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

  void _showRaceContextMenu(Race race, BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ContextMenu.race(
        race: race,
        onEdit: () => _editRace(race),
        onDelete: () => _deleteRace(race),
      ),
    );
  }

  Future<void> _editRace(Race race) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => RaceManagementPage(race: race)),
    );
    if (result == true && mounted) {
      _filterRaces(_searchController.text, Hive.box<Race>('races').values.toList());
    }
  }

  Future<void> _reorderRaces(int oldIndex, int newIndex) async {
    if (oldIndex == newIndex) return;

    final box = Hive.box<Race>('races');
    final races = box.values.toList();

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final race = races.removeAt(oldIndex);
    races.insert(newIndex, race);

    await box.clear();
    await box.addAll(races);

    if (mounted) {
      setState(() {
        _filterRaces(_searchController.text, box.values.toList());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isWideScreen = MediaQuery.of(context).size.width > 1000;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Поиск рас...',
            border: InputBorder.none,
            hintStyle: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          style: textTheme.bodyLarge,
          onChanged: (query) => _filterRaces(query, Hive.box<Race>('races').values.toList()),
        )
            : Text('Расы', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
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
                  _filteredRaces = [];
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage())),
          ),
        ],
      ),
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
            child: ValueListenableBuilder<Box<Race>>(
              valueListenable: Hive.box<Race>('races').listenable(),
              builder: (context, box, _) {
                final allRaces = box.values.toList();
                final tags = _generateTags(allRaces);
                final racesToShow = _isSearching || _selectedTag != null
                    ? _filteredRaces
                    : allRaces;

                return isWideScreen
                    ? _buildWideLayout(allRaces, racesToShow, tags, colorScheme, textTheme)
                    : _buildMobileLayout(allRaces, racesToShow, tags, colorScheme, textTheme);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: CustomFloatingButtons(
        onImport: _importRaceFromFile,
        onAdd: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (context) => const RaceManagementPage()),
          );
          if (result == true && mounted) {
            _filterRaces(_searchController.text,
                Hive.box<Race>('races').values.toList());
          }
        },
      ),
    );
  }

  Widget _buildWideLayout(
      List<Race> allRaces,
      List<Race> racesToShow,
      List<String> tags,
      ColorScheme colorScheme,
      TextTheme textTheme,
      ) {
    return Row(
      children: [
        Container(
          width: 400,
          decoration: BoxDecoration(
            border: Border(right: BorderSide(color: colorScheme.outline)),
          ),
          child: Column(
            children: [
              if (tags.isNotEmpty)
                SizedBox(
                  height: 56,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    scrollDirection: Axis.horizontal,
                    itemCount: tags.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 4),
                    itemBuilder: (context, index) {
                      final tag = tags[index];
                      return FilterChip(
                        label: Text(tag),
                        selected: _selectedTag == tag,
                        onSelected: (selected) => setState(() {
                          _selectedTag = selected ? tag : null;
                          _filterRaces(_searchController.text, allRaces);
                        }),
                        shape: StadiumBorder(
                          side: BorderSide(color: colorScheme.outline),
                        ),
                        showCheckmark: false,
                        side: BorderSide.none,
                        selectedColor: colorScheme.secondaryContainer,
                        labelStyle: textTheme.labelLarge?.copyWith(
                          color: _selectedTag == tag
                              ? colorScheme.onSecondaryContainer
                              : colorScheme.onSurface,
                        ),
                      );
                    },
                  ),
                ),
              Expanded(
                child: racesToShow.isEmpty
                    ? _buildEmptyState(colorScheme, textTheme)
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: racesToShow.length,
                  itemBuilder: (context, index) => _buildRaceItem(
                    racesToShow[index],
                    colorScheme,
                    textTheme,
                    isSelected: _selectedRace?.key == racesToShow[index].key,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _selectedRace != null
              ? RaceManagementPage(race: _selectedRace!)
              : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.emoji_people,
                  size: 48,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'Выберите расу',
                  style: textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_people,
            size: 48,
            color: colorScheme.onSurface,
          ),
          const SizedBox(height: 16),
          Text(
            _isSearching && _searchController.text.isNotEmpty
                ? 'Ничего не найдено'
                : 'Нет созданных рас',
            style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(
      List<Race> allRaces,
      List<Race> racesToShow,
      List<String> tags,
      ColorScheme colorScheme,
      TextTheme textTheme,
      ) {
    return Column(
      children: [
        if (tags.isNotEmpty)
          SizedBox(
            height: 56,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemCount: tags.length,
              separatorBuilder: (_, __) => const SizedBox(width: 4),
              itemBuilder: (context, index) {
                final tag = tags[index];
                return FilterChip(
                  label: Text(tag),
                  selected: _selectedTag == tag,
                  onSelected: (selected) => setState(() {
                    _selectedTag = selected ? tag : null;
                    _filterRaces(_searchController.text, allRaces);
                  }),
                  shape: StadiumBorder(side: BorderSide(color: colorScheme.outline)),
                  showCheckmark: false,
                  side: BorderSide.none,
                  selectedColor: colorScheme.secondaryContainer,
                  labelStyle: textTheme.labelLarge?.copyWith(
                    color: _selectedTag == tag
                        ? colorScheme.onSecondaryContainer
                        : colorScheme.onSurface,
                  ),
                );
              },
            ),
          ),
        Expanded(
          child: _buildRacesList(racesToShow),
        ),
      ],
    );
  }

  Widget _buildRaceItem(
      Race race,
      ColorScheme colorScheme,
      TextTheme textTheme, {
        bool isSelected = false,
      }) {
    return Card(
      key: ValueKey(race.key),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      elevation: 0,
      color: isSelected ? colorScheme.secondaryContainer : colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? colorScheme.secondary : colorScheme.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (MediaQuery.of(context).size.width > 1000) {
            setState(() => _selectedRace = race);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RaceManagementPage(race: race)),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _buildRaceAvatar(race, colorScheme),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(race.name, style: textTheme.bodyLarge),
                    Text(
                      race.description.isNotEmpty ? race.description : 'Нет описания',
                      style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.more_vert, color: colorScheme.onSurfaceVariant),
                onPressed: () => _showRaceContextMenu(race, context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRacesList(List<Race> races) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    if (races.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_people, size: 48, color: colorScheme.onSurface),
            const SizedBox(height: 16),
            Text(
              _isSearching && _searchController.text.isNotEmpty
                  ? 'Ничего не найдено'
                  : 'Нет созданных рас',
              style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
            ),
          ],
        ),
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: races.length,
      itemBuilder: (context, index) => _buildRaceItem(
        races[index],
        colorScheme,
        textTheme,
        isSelected: _selectedRace?.key == races[index].key,
      ),
      onReorder: (oldIndex, newIndex) async {
        await _reorderRaces(oldIndex, newIndex);
      },
    );
  }

  Widget _buildRaceAvatar(Race race, ColorScheme colorScheme) {
    return race.logo != null
        ? CircleAvatar(backgroundImage: MemoryImage(race.logo!), radius: 28)
        : CircleAvatar(
      radius: 28,
      backgroundColor: colorScheme.surfaceContainerHighest,
      child: Icon(Icons.emoji_people, color: colorScheme.onSurfaceVariant),
    );
  }
}