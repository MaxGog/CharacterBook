import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../generated/l10n.dart';
import '../../../models/character_model.dart';
import '../../../models/template_model.dart';
import '../../../services/file_picker_service.dart';
import '../../widgets/context_menu.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_floating_buttons.dart';
import '../templates/templates_page.dart';
import 'character_detail_page.dart';
import 'character_management_page.dart';

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
  Character? _selectedCharacter;
  final FilePickerService _filePickerService = FilePickerService();

  List<String> _generateTags(List<Character> characters) {
    final s = S.of(context);
    return [
      s.male, s.female, s.another,
      s.children, s.young, s.adults, s.elderly,
      s.short_name,
      s.a_to_z, s.z_to_a, s.age_asc, s.age_desc
    ];
  }

  void _filterCharacters(String query, List<Character> allCharacters) {
    setState(() {
      final s = S.of(context);

      List<Character> filtered = allCharacters.where((character) {
        final matchesSearch = query.isEmpty ||
            character.name.toLowerCase().contains(query.toLowerCase()) ||
            character.age.toString().contains(query);

        bool matchesTag = true;
        if (_selectedTag != null) {
          if (_selectedTag == s.male) {
            matchesTag = character.gender == 'male';
          } else if (_selectedTag == s.female) {
            matchesTag = character.gender == 'female';
          } else if (_selectedTag == s.another) {
            matchesTag = character.gender == 'another';
          } else if (_selectedTag == s.short_name) {
            matchesTag = character.name.length <= 4;
          } else if (_selectedTag == s.children) {
            matchesTag = character.age < 18;
          } else if (_selectedTag == s.young) {
            matchesTag = character.age < 30;
          } else if (_selectedTag == s.adults) {
            matchesTag = character.age < 50;
          } else if (_selectedTag == s.elderly) {
            matchesTag = character.age >= 50;
          }
        }

        return matchesSearch && matchesTag;
      }).toList();

      if (_selectedTag == s.a_to_z) {
        filtered.sort((a, b) => a.name.compareTo(b.name));
      } else if (_selectedTag == s.z_to_a) {
        filtered.sort((a, b) => b.name.compareTo(a.name));
      } else if (_selectedTag == s.age_asc) {
        filtered.sort((a, b) => a.age.compareTo(b.age));
      } else if (_selectedTag == s.age_desc) {
        filtered.sort((a, b) => b.age.compareTo(a.age));
      }

      _filteredCharacters = filtered;

      if (_selectedCharacter != null && !filtered.contains(_selectedCharacter)) {
        _selectedCharacter = null;
      }
    });
  }

  String _getLocalizedGender(String genderKey) {
    final s = S.of(context);
    switch (genderKey) {
      case 'male': return s.male;
      case 'female': return s.female;
      case 'another': return s.another;
      default: return genderKey;
    }
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

      _showSnackBar(S.of(context).character_imported(character.name));
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ContextMenu.character(
        character: character,
        onEdit: () => _editCharacter(character),
        onDelete: () => _deleteCharacter(character),
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

  Future<void> _createFromTemplate() async {
    final template = await Navigator.push<QuestionnaireTemplate>(
      context,
      MaterialPageRoute(builder: (context) => const TemplatesPage()),
    );

    if (template != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CharacterEditPage(
            character: template.applyToCharacter(Character.empty()),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWideScreen = MediaQuery.of(context).size.width > 1000;

    return Scaffold(
      appBar: CustomAppBar(
          title: S.of(context).my_characters,
          isSearching: _isSearching,
          searchController: _searchController,
          searchHint: S.of(context).search_characters,
          onSearchToggle: () => setState(() {
            _isSearching = !_isSearching;
            if (!_isSearching) {
              _searchController.clear();
              _selectedTag = null;
              _filteredCharacters = [];
            }
          }),
          onSearchChanged: (query) {
            final allCharacters = Hive.box<Character>('characters').values.toList().cast<Character>();
            _filterCharacters(query, allCharacters);
          },
          onTemplatesPressed: _createFromTemplate
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
      floatingActionButton: CustomFloatingButtons(
        onImport: _importCharacter,
        onAdd: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CharacterEditPage()),
        ),
        onTemplate: _createFromTemplate,
      ),
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
                  S.of(context).select_character,
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
                      '${character.age} ${S.of(context).years}, ${_getLocalizedGender(character.gender)}',
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
                  ? S.of(context).nothing_found
                  : S.of(context).no_characters,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            if (!_isSearching)
              TextButton(
                onPressed: _importCharacter,
                child: Text(S.of(context).import_character),
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

  Future<void> _deleteCharacter(Character character) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).character_delete_title),
        content: Text(S.of(context).character_delete_confirm),
        actions: [
          TextButton(
            child: Text(
              S.of(context).cancel,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text(
              S.of(context).delete,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await Hive.box<Character>('characters').delete(character.key);
      if (mounted) _showSnackBar(S.of(context).character_deleted);
    }
  }
}