import 'package:characterbook/data/enums/character_sort_enum.dart';
import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/data/models/character_model.dart';
import 'package:characterbook/data/repositories/character_repository.dart';
import 'package:characterbook/data/services/character_service.dart';
import 'package:characterbook/services/app_navigator.dart';
import 'package:characterbook/services/file_picker_service.dart';
import 'package:characterbook/services/pin_service.dart';
import 'package:characterbook/ui/widgets/dialogs/share_options_dialog.dart';
import 'package:characterbook/ui/widgets/modals/character_modal_card.dart';
import 'package:characterbook/ui/controllers/character_list_controller.dart';
import 'package:characterbook/ui/widgets/common_fab_menu.dart';
import 'package:characterbook/ui/widgets/list/list_state_indicator.dart';
import 'package:characterbook/ui/widgets/items/character_card_item.dart';
import 'package:characterbook/ui/widgets/tag_filter.dart';
import 'package:characterbook/ui/widgets/tools_context_menu.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class _TagGroup {
  final String tag;
  final List<Character> characters;
  const _TagGroup({required this.tag, required this.characters});
}

class CharacterListScreen extends StatefulWidget {
  const CharacterListScreen({super.key});

  @override
  State<CharacterListScreen> createState() => _CharacterListScreenState();
}

class _CharacterListScreenState extends State<CharacterListScreen> {
  final TextEditingController _searchController = TextEditingController();

  bool _isSearching = false;
  bool _isImporting = false;
  bool _isFabVisible = true;
  final bool _isTagsVisible = true;
  bool _isGroupByTagMode = false;
  String? _errorMessage;
  String? _animatingHeroId;

  final Map<String, bool> _expandedGroups = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _startSearch() => setState(() => _isSearching = true);
  void _stopSearch() {
    setState(() => _isSearching = false);
    _searchController.clear();
  }

  void _toggleGroupMode(CharacterListController controller) {
    setState(() => _isGroupByTagMode = !_isGroupByTagMode);
    controller.setSelectedTag(null);
    if (_isGroupByTagMode) {
      _expandedGroups.clear();
    }
  }

  List<String> _getTags(
      BuildContext context, CharacterListController controller) {
    final s = S.of(context);
    return [
      s.a_to_z,
      s.z_to_a,
      s.age_asc,
      s.age_desc,
      ...controller.allTags,
    ];
  }

  void _onTagSelected(
      String? tag, BuildContext context, CharacterListController controller) {
    if (tag == null) {
      controller.setSelectedTag(null);
      return;
    }
    final s = S.of(context);
    if (tag == s.a_to_z) {
      controller.setSort(CharacterSort.nameAsc);
    } else if (tag == s.z_to_a) {
      controller.setSort(CharacterSort.nameDesc);
    } else if (tag == s.age_asc) {
      controller.setSort(CharacterSort.ageAsc);
    } else if (tag == s.age_desc) {
      controller.setSort(CharacterSort.ageDesc);
    } else {
      if (controller.selectedTag == tag) {
        controller.setSelectedTag(null);
      } else {
        controller.setSelectedTag(tag);
      }
    }
  }

  Future<void> _importCharacter(
      BuildContext context, CharacterService service) async {
    setState(() {
      _isImporting = true;
      _errorMessage = null;
    });
    try {
      final character = await context
          .read<CharacterListController>()
          .importCharacter(() => FilePickerService().importCharacter(), service);
      if (mounted && character != null) {
        AppNavigator.showSuccess(S.of(context).character_imported(character.name));
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  Future<bool> _showDeleteConfirmation(String title, String content) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(S.of(context).cancel)),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(S.of(context).delete,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
            ],
          ),
        ) ??
        false;
  }


  void _navigateToDetail(Character character) {
    setState(() => _animatingHeroId = character.id);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CharacterModalCard(character: character),
    ).then((_) {
      if (mounted) {
        setState(() => _animatingHeroId = null);
      } 
    });
  }

  void _navigateToEdit(BuildContext context, [Character? character]) {
    if (character != null) {
      AppNavigator.editCharacter(character);
    } else {
      AppNavigator.openNewCharacter();
    }
  }

  Future<void> _createFromTemplate(BuildContext context) async {
    final template = await AppNavigator.openTemplates();
    if (template != null && mounted) {
      AppNavigator.openNewCharacter(template: template);
    }
  }

  Future<void> _deleteCharacter(
      Character character, CharacterListController controller) async {
    final confirmed = await _showDeleteConfirmation(
      S.of(context).character_delete_title,
      S.of(context).character_delete_confirm,
    );
    if (confirmed) {
      await controller.deleteCharacter(character);
      if (mounted) AppNavigator.showSuccess(S.of(context).character_deleted);
    }
  }

  void _showCharacterContextMenu(
    Character character,
    BuildContext context,
    CharacterListController controller,
    CharacterService service,
  ) {
    final s = S.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FutureBuilder<bool>(
        future: PinService.isPinned(character.id),
        builder: (context, snapshot) {
          final isPinned = snapshot.data ?? false;
          return ContextMenu.character(
            character: character,
            onEdit: () => _navigateToEdit(context, character),
            onDelete: () => _deleteCharacter(character, controller),
            onDuplicate: () async {
              try {
                await controller.duplicateCharacter(character, service);
                if (context.mounted) AppNavigator.showSuccess(s.character_duplicated);
              } catch (e) {
                if (context.mounted) AppNavigator.showError('${s.duplicate_error}: $e');
              }
            },
            onShare: () {
              ShareOptionsDialog.show(
                context,
                onCopy: () async {
                  try {
                    await controller.characterClipboardText(character, context);
                    if (context.mounted) AppNavigator.showSuccess(s.copied_to_clipboard);
                  } catch (e) {
                    if (context.mounted) AppNavigator.showError('${s.copy_error}: $e');
                  }
                },
                onShareFile: () async {
                  try {
                    await controller.shareCharacterAsFile(character);
                  } catch (e) {
                    if (context.mounted) AppNavigator.showError('${s.error}: $e');
                  }
                },
                onExportPdf: () async {
                  try {
                    await controller.exportCharacterToPdf(character, context);
                  } catch (e) {
                    if (context.mounted) AppNavigator.showError('${s.export_error}: $e');
                  }
                },
                onExportWord: () async {
                  try {
                    await controller.exportCharacterToWord(
                        character, context);
                  } catch (e) {
                    if (context.mounted) {
                      AppNavigator.showError('${s.export_error}: $e');
                    }
                  }
                },
              );
            },
            onPin: () async {
              final pinned = await PinService.togglePinned(character.id);
              if (context.mounted) {
                AppNavigator.showSuccess(pinned ? s.pin_success : s.unpin_success);
              }
            },
            pinLabel: isPinned ? s.unpin : s.pin,
            pinIcon: isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
          );
        },
      ),
    );
  }

  List<_TagGroup> _buildTagGroups(List<Character> characters) {
    final Map<String, List<Character>> groups = {};
    final List<Character> noTag = [];

    for (final char in characters) {
      if (char.tags.isEmpty) {
        noTag.add(char);
        continue;
      }
      for (final tag in char.tags) {
        groups.putIfAbsent(tag, () => []).add(char);
      }
    }

    final List<_TagGroup> result = [];
    final sortedTags = groups.keys.toList()..sort();
    for (final tag in sortedTags) {
      result.add(_TagGroup(tag: tag, characters: groups[tag]!));
    }
    if (noTag.isNotEmpty) {
      result.add(
          _TagGroup(tag: S.of(context).no_folder_selected, characters: noTag));
    }
    return result;
  }

  Widget _buildGroupHeader(String tag, bool isExpanded, int count) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => setState(() => _expandedGroups[tag] = !isExpanded),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                tag,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              '$count',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          CharacterListController(context.read<CharacterRepository>()),
      child: Consumer<CharacterListController>(
        builder: (context, controller, child) {
          final service = context.read<CharacterService>();
          final s = S.of(context);
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;

          return Scaffold(
            key: const PageStorageKey('characterList'),
            body: NotificationListener<ScrollUpdateNotification>(
              onNotification: (notification) {
                final metrics = notification.metrics;
                final delta = notification.scrollDelta ?? 0;
                if (metrics.pixels <= metrics.minScrollExtent) {
                  if (!_isFabVisible) {
                    setState(() {
                      _isFabVisible = true;
                    });
                  }
                } else if (delta > 0) {
                  if (_isFabVisible) {
                    setState(() {
                      _isFabVisible = false;
                    });
                  }
                } else if (delta < 0) {
                  if (!_isFabVisible) {
                    setState(() {
                      _isFabVisible = true;
                    });
                  }
                }
                return false;
              },
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  SliverAppBar.large(
                    pinned: true,
                    leading: _isSearching
                        ? IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: _stopSearch,
                          )
                        : null,
                    title: _isSearching ? null : Text(s.my_characters),
                    actions: [
                      if (!_isSearching) ...[
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: _startSearch,
                        ),
                        IconButton(
                          icon: const Icon(Icons.account_circle_rounded),
                          iconSize: 32,
                          tooltip: s.more_options,
                          onPressed: () => AppNavigator.openMenu(context),
                        ),
                      ] else ...[
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              controller.setSearchQuery('');
                            },
                          ),
                      ],
                    ],
                    bottom: _isSearching
                        ? PreferredSize(
                            preferredSize:
                                const Size.fromHeight(kToolbarHeight),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                              child: SearchBar(
                                controller: _searchController,
                                hintText: s.search_characters,
                                leading: const Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: Icon(Icons.search),
                                ),
                                padding: const WidgetStatePropertyAll(
                                  EdgeInsets.symmetric(horizontal: 8),
                                ),
                                shape: WidgetStatePropertyAll(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                backgroundColor: WidgetStatePropertyAll(
                                  colorScheme.surfaceContainerHigh,
                                ),
                                elevation: const WidgetStatePropertyAll(0),
                                onChanged: (query) =>
                                    controller.setSearchQuery(query),
                                onSubmitted: (query) =>
                                    controller.setSearchQuery(query),
                              ),
                            ),
                          )
                        : null,
                  ),
                ],
                body: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: ListStateIndicator(
                        isLoading: _isImporting || controller.isLoading,
                        errorMessage: _errorMessage ?? controller.error,
                        onErrorClose: () =>
                            setState(() => _errorMessage = null),
                      ),
                    ),
                    if (controller.allTags.isNotEmpty)
                      SliverToBoxAdapter(
                        child: AnimatedCrossFade(
                          duration: const Duration(milliseconds: 300),
                          crossFadeState: _isTagsVisible
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                          firstChild: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: Row(
                              children: [
                                ActionChip(
                                  avatar: Icon(
                                    _isGroupByTagMode
                                        ? Icons.folder_open
                                        : Icons.folder_outlined,
                                    size: 18,
                                  ),
                                  label: Text(
                                    _isGroupByTagMode
                                        ? s.list_mode
                                        : s.folder_mode,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  onPressed: () => _toggleGroupMode(controller),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TagFilter(
                                    tags: _getTags(context, controller),
                                    selectedTag: controller.selectedTag,
                                    onTagSelected: (tag) => _onTagSelected(
                                        tag, context, controller),
                                    context: context,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          secondChild: const SizedBox.shrink(),
                        ),
                      ),
                    if (controller.filteredItems.isEmpty)
                      SliverFillRemaining(
                        child: Center(
                          child: Text(s.no_characters,
                              style: theme.textTheme.bodyLarge),
                        ),
                      )
                    else if (_isGroupByTagMode)
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final groups =
                                _buildTagGroups(controller.filteredItems);
                            if (index >= groups.length) return null;
                            final group = groups[index];
                            final isExpanded =
                                _expandedGroups[group.tag] ?? true;

                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildGroupHeader(group.tag, isExpanded,
                                    group.characters.length),
                                AnimatedSize(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                  child: isExpanded
                                      ? Column(
                                          children: group.characters
                                              .map((character) =>
                                                  CharacterCardItem(
                                                    key: ValueKey(character.key),
                                                    animateHero:
                                                        _animatingHeroId !=
                                                            character.id,
                                                    character: character,
                                                    isSelected: false,
                                                    onTap: () =>
                                                        _navigateToDetail(
                                                            character),
                                                    onLongPress: () =>
                                                        _showCharacterContextMenu(
                                                            character,
                                                            context,
                                                            controller,
                                                            service),
                                                    onEdit: () =>
                                                        _navigateToEdit(
                                                            context, character),
                                                    onDelete: () =>
                                                        _deleteCharacter(
                                                            character,
                                                            controller),
                                                    onDuplicate: () => service
                                                        .duplicateCharacter(
                                                            character),
                                                    onSettings: () => AppNavigator
                                                        .openSwipeActionSettings(),
                                                    onShare: () =>
                                                        service.exportToPdf(
                                                            context, character),
                                                  ))
                                              .toList(),
                                        )
                                      : const SizedBox.shrink(),
                                ),
                              ],
                            );
                          },
                          childCount:
                              _buildTagGroups(controller.filteredItems).length,
                        ),
                      )
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final character = controller.filteredItems[index];
                            return CharacterCardItem(
                              key: ValueKey(character.key),
                              character: character,
                              isSelected: false,
                              animateHero: _animatingHeroId != character.id,
                              onTap: () => _navigateToDetail(character),
                              onLongPress: () => _showCharacterContextMenu(
                                  character, context, controller, service),
                              onEdit: () => _navigateToEdit(context, character),
                              onDelete: () =>
                                  _deleteCharacter(character, controller),
                              onDuplicate: () =>
                                  service.duplicateCharacter(character),
                              onSettings: () =>
                                  AppNavigator.openSwipeActionSettings(),
                              onShare: () =>
                                  service.exportToPdf(context, character),
                            );
                          },
                          childCount: controller.filteredItems.length,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            floatingActionButton: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isFabVisible
                  ? CommonListFloatingButtons(
                      onImport: () => _importCharacter(context, service),
                      onAdd: () => _navigateToEdit(context),
                      onTemplate: () => _createFromTemplate(context),
                      heroTag: "character_list",
                    )
                  : const SizedBox.shrink(),
            ),
          );
        },
      ),
    );
  }
}
