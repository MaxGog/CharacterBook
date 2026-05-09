import 'package:characterbook/data/enums/race_sort_enum.dart';
import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/data/models/character_model.dart';
import 'package:characterbook/data/models/race_model.dart';
import 'package:characterbook/data/repositories/race_repository.dart';
import 'package:characterbook/data/services/race_service.dart';
import 'package:characterbook/services/app_navigator.dart';
import 'package:characterbook/services/file_picker_service.dart';
import 'package:characterbook/ui/controllers/race_list_controller.dart';
import 'package:characterbook/ui/navigation/menu_content.dart';
import 'package:characterbook/ui/screens/settings/swipe_action_settings_screen.dart';
import 'package:characterbook/ui/widgets/dialogs/share_options_dialog.dart';
import 'package:characterbook/ui/widgets/tools_context_menu.dart';
import 'package:characterbook/ui/widgets/common_fab_menu.dart';
import 'package:characterbook/ui/widgets/items/race_card_item.dart';
import 'package:characterbook/ui/widgets/modals/race_modal_card.dart';
import 'package:characterbook/ui/widgets/list/list_state_indicator.dart';
import 'package:characterbook/ui/widgets/tag_filter.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'race_management_screen.dart';

class _RaceGroup {
  final String tag;
  final List<Race> races;
  const _RaceGroup({required this.tag, required this.races});
}

class RaceListScreen extends StatefulWidget {
  const RaceListScreen({super.key});

  @override
  State<RaceListScreen> createState() => _RaceListScreenState();
}

class _RaceListScreenState extends State<RaceListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Box<Character> _charactersBox = Hive.box<Character>('characters');

  bool _isSearching = false;
  bool _isImporting = false;
  bool _isFabVisible = true;
  bool _isTagsVisible = true;
  bool _isGroupByTagMode = false;
  String? _errorMessage;

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

  void _toggleGroupMode(RaceListController controller) {
    setState(() => _isGroupByTagMode = !_isGroupByTagMode);
    controller.setSelectedTag(null);
    if (_isGroupByTagMode) {
      _expandedGroups.clear();
    }
  }

  Future<bool> _isRaceUsed(Race race) async {
    final characters = _charactersBox.values;
    return characters.any((character) => character.race?.key == race.key);
  }

  Future<void> _deleteRace(
      Race race, RaceListController controller, RaceService service) async {
    if (await _isRaceUsed(race)) {
      _showRaceInUseDialog();
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(context).race_delete_title),
        content: Text(S.of(context).race_delete_confirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(S.of(context).cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(S.of(context).delete,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await controller.deleteRace(race.key);
      if (mounted) AppNavigator.showSuccess(S.of(context).race_deleted);
    }
  }

  void _showRaceInUseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).race_delete_error_title),
        content: Text(S.of(context).race_delete_error_content),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(S.of(context).ok)),
        ],
      ),
    );
  }

  void _showRaceContextMenu(Race race, BuildContext context,
      RaceListController controller, RaceService service) {
    final s = S.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ContextMenu.race(
        race: race,
        onEdit: () => _editRace(context, race),
        onDelete: () => _deleteRace(race, controller, service),
        onShare: () {
          ShareOptionsDialog.show(
            context,
            onCopy: () async {
              try {
                await controller.raceClipboardText(race, context);
                if (context.mounted) AppNavigator.showSuccess(s.copied_to_clipboard);
              } catch (e) {
                if (context.mounted) AppNavigator.showError('${s.copy_error}: $e');
              }
            },
            onShareFile: () async {
              try {
                await controller.shareRaceAsFile(race);
              } catch (e) {
                if (context.mounted) AppNavigator.showError('${s.error}: $e');
              }
            },
            onExportPdf: () async {
              try {
                await controller.exportRaceToPdf(race, context);
              } catch (e) {
                if (context.mounted) AppNavigator.showError('${s.export_error}: $e');
              }
            },
            onExportWord: () async {
              try {
                await controller.exportRaceToWord(race, context);
              } catch (e) {
                if (context.mounted) {
                  AppNavigator.showError('${s.export_error}: $e');
                }
              }
            },
          );
        },
      ),
    );
  }

  Future<void> _editRace(BuildContext context, Race race) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RaceModalCard(race: race),
    );
  }

  Future<void> _importRace(BuildContext context, RaceService service) async {
    setState(() {
      _isImporting = true;
      _errorMessage = null;
    });
    try {
      final race = await context.read<RaceListController>().importRace(
            () => FilePickerService().importRace(),
            service,
          );
      if (mounted && race != null) {
        AppNavigator.showSuccess(S.of(context).race_imported(race.name));
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  void _showAccountMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 4),
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                        tooltip: S.of(context).close,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: MenuContent(scrollController: scrollController),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _handleCreateRace(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RaceManagementScreen()),
    );
  }

  List<String> _getTags(BuildContext context, RaceListController controller) {
    final s = S.of(context);
    return [
      s.a_to_z,
      s.z_to_a,
      ...controller.allTags,
    ];
  }

  void _onTagSelected(
      String? tag, BuildContext context, RaceListController controller) {
    if (tag == null) {
      controller.setSelectedTag(null);
      return;
    }
    final s = S.of(context);
    if (tag == s.a_to_z) {
      controller.setSort(RaceSort.nameAsc);
    } else if (tag == s.z_to_a) {
      controller.setSort(RaceSort.nameDesc);
    } else {
      if (controller.selectedTag == tag) {
        controller.setSelectedTag(null);
      } else {
        controller.setSelectedTag(tag);
      }
    }
  }

  List<_RaceGroup> _buildRaceGroups(List<Race> races) {
    final Map<String, List<Race>> groups = {};
    final List<Race> noTag = [];

    for (final race in races) {
      if (race.tags.isEmpty) {
        noTag.add(race);
        continue;
      }
      for (final tag in race.tags) {
        groups.putIfAbsent(tag, () => []).add(race);
      }
    }

    final List<_RaceGroup> result = [];
    final sortedTags = groups.keys.toList()..sort();
    for (final tag in sortedTags) {
      result.add(_RaceGroup(tag: tag, races: groups[tag]!));
    }
    if (noTag.isNotEmpty) {
      result
          .add(_RaceGroup(tag: S.of(context).no_folder_selected, races: noTag));
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
      create: (_) => RaceListController(context.read<RaceRepository>()),
      child: Consumer<RaceListController>(
        builder: (context, controller, child) {
          final service = context.read<RaceService>();
          final s = S.of(context);
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;

          return Scaffold(
            body: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollUpdateNotification) {
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
                } else if (notification is ScrollEndNotification) {
                  final metrics = notification.metrics;
                  if (metrics.pixels <= metrics.minScrollExtent) {
                    if (!_isFabVisible || !_isTagsVisible) {
                      setState(() {
                        _isFabVisible = true;
                        _isTagsVisible = true;
                      });
                    }
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
                    title: _isSearching ? null : Text(s.races),
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
                          onPressed: _showAccountMenu,
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
                                hintText: s.search_race_hint,
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
                          child: Text(s.empty_list,
                              style: theme.textTheme.bodyLarge),
                        ),
                      )
                    else if (_isGroupByTagMode)
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final groups =
                                _buildRaceGroups(controller.filteredItems);
                            if (index >= groups.length) return null;
                            final group = groups[index];
                            final isExpanded =
                                _expandedGroups[group.tag] ?? true;

                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildGroupHeader(
                                    group.tag, isExpanded, group.races.length),
                                AnimatedSize(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                  child: isExpanded
                                      ? Column(
                                          children: group.races
                                              .map((race) => RaceCardItem(
                                                    key: ValueKey(race.key),
                                                    race: race,
                                                    onTap: () => _editRace(
                                                        context, race),
                                                    onLongPress: () =>
                                                        _showRaceContextMenu(
                                                            race,
                                                            context,
                                                            controller,
                                                            service),
                                                    onShare: () =>
                                                        service.exportToPdf(
                                                            context, race),
                                                    onSettings: () =>
                                                        Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) =>
                                                            const SwipeActionSettingsScreen(),
                                                      ),
                                                    ),
                                                  ))
                                              .toList(),
                                        )
                                      : const SizedBox.shrink(),
                                ),
                              ],
                            );
                          },
                          childCount:
                              _buildRaceGroups(controller.filteredItems).length,
                        ),
                      )
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final race = controller.filteredItems[index];
                            return RaceCardItem(
                              key: ValueKey(race.key),
                              race: race,
                              onTap: () => _editRace(context, race),
                              onLongPress: () => _showRaceContextMenu(
                                  race, context, controller, service),
                              onShare: () => service.exportToPdf(context, race),
                              onSettings: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const SwipeActionSettingsScreen(),
                                ),
                              ),
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
                      onImport: () => _importRace(context, service),
                      onAdd: () => _handleCreateRace(context),
                      heroTag: "race_list",
                    )
                  : const SizedBox.shrink(),
            ),
          );
        },
      ),
    );
  }
}
