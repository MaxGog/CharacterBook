import 'package:characterbook/data/enums/race_sort_enum.dart';
import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/data/models/character_model.dart';
import 'package:characterbook/data/models/race_model.dart';
import 'package:characterbook/data/repositories/race_repository.dart';
import 'package:characterbook/data/services/race_service.dart';
import 'package:characterbook/ui/controllers/race_list_controller.dart';

import 'package:characterbook/ui/screens/settings/swipe_action_settings_screen.dart';
import 'package:characterbook/ui/widgets/dialogs/share_options_dialog.dart';
import 'package:characterbook/ui/widgets/tools_context_menu.dart';
import 'package:characterbook/ui/widgets/appbar/common_main_app_bar.dart';
import 'package:characterbook/ui/widgets/buttons/common_fab_menu.dart';
import 'package:characterbook/ui/widgets/items/race_card_item.dart';
import 'package:characterbook/ui/widgets/modals/race_modal_card.dart';
import 'package:characterbook/ui/widgets/list/list_state_indicator.dart';
import 'package:characterbook/ui/widgets/list/optimized_list_view.dart';
import 'package:characterbook/ui/widgets/list/grouped_tag_list.dart';
import 'package:characterbook/ui/widgets/tags/tag_filter.dart';
import 'package:characterbook/ui/widgets/mixins/list_page_mixin.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'race_management_screen.dart';

class RaceListScreen extends StatefulWidget {
  const RaceListScreen({super.key});

  @override
  State<RaceListScreen> createState() => _RaceListScreenState();
}

class _RaceListScreenState extends State<RaceListScreen>
    with ListPageMixin<RaceListScreen> {
  final Box<Character> _charactersBox = Hive.box<Character>('characters');

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

  void _toggleGroupMode(RaceListController controller) {
    toggleGroupByTagMode();
    controller.setSelectedTag(null);
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
    final confirmed = await showDeleteConfirmationDialog(
      S.of(context).race_delete_title,
      S.of(context).race_delete_confirm,
    );
    if (confirmed) {
      await controller.deleteRace(race.key);
      if (mounted) {
        showSnackBar(S.of(context).race_deleted);
      }
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
            child: Text(S.of(context).ok),
          ),
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
                if (context.mounted) showSnackBar(s.copied_to_clipboard);
              } catch (e) {
                if (context.mounted) showSnackBar('${s.copy_error}: $e');
              }
            },
            onShareFile: () async {
              try {
                await controller.shareRaceAsFile(race);
              } catch (e) {
                if (context.mounted) showSnackBar('${s.error}: $e');
              }
            },
            onExportPdf: () async {
              try {
                await controller.exportRaceToPdf(race, context);
              } catch (e) {
                if (context.mounted) showSnackBar('${s.export_error}: $e');
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
      isImporting = true;
      errorMessage = null;
    });
    try {
      final race = await context.read<RaceListController>().importRace(
            () => filePickerService.importRace(),
            service,
          );
      if (mounted && race != null) {
        showSnackBar(S.of(context).race_imported(race.name));
      }
    } catch (e) {
      setState(() => errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => isImporting = false);
    }
  }

  void _handleCreateRace(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RaceManagementScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RaceListController(
        context.read<RaceRepository>(),
      ),
      child: Consumer<RaceListController>(
        builder: (context, controller, child) {
          final service = context.read<RaceService>();
          final s = S.of(context);
          return Scaffold(
            appBar: CommonMainAppBar(
              title: s.races,
              isSearching: isSearching,
              searchController: searchController,
              searchHint: s.search_race_hint,
              onSearchToggle: () {
                setState(() {
                  isSearching = !isSearching;
                  if (!isSearching) {
                    searchController.clear();
                    controller.setSearchQuery('');
                  }
                });
              },
              onSearchChanged: (query) => controller.setSearchQuery(query),
            ),
            body: Column(
              children: [
                ListStateIndicator(
                  isLoading: isImporting || controller.isLoading,
                  errorMessage: errorMessage ?? controller.error,
                  onErrorClose: () {
                    setState(() => errorMessage = null);
                  },
                ),
                Expanded(
                  child: Column(
                    children: [
                      if (controller.allTags.isNotEmpty)
                        AnimatedCrossFade(
                          duration: const Duration(milliseconds: 300),
                          reverseDuration: const Duration(milliseconds: 300),
                          firstCurve: Curves.easeInOutCubic,
                          secondCurve: Curves.easeInOutCubic,
                          firstChild: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                height: 40,
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      child: ActionChip(
                                        avatar: Icon(
                                          isGroupByTagMode
                                              ? Icons.folder_open
                                              : Icons.folder_outlined,
                                          size: 18,
                                        ),
                                        label: Text(
                                          isGroupByTagMode
                                              ? s.list_mode
                                              : s.folder_mode,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        onPressed: () =>
                                            _toggleGroupMode(controller),
                                      ),
                                    ),
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
                            ],
                          ),
                          secondChild: const SizedBox.shrink(),
                          crossFadeState: isTagsVisible
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                        ),
                      Expanded(
                        child: isGroupByTagMode
                            ? GroupedTagList<Race>(
                                items: controller.filteredItems,
                                getItemTags: (race) => race.tags,
                                itemBuilder: (ctx, race) => RaceCardItem(
                                  key: ValueKey(race.key),
                                  race: race,
                                  onTap: () => _editRace(context, race),
                                  onLongPress: () => _showRaceContextMenu(
                                      race, context, controller, service),
                                  onShare: () =>
                                      service.exportToPdf(context, race),
                                  onSettings: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const SwipeActionSettingsScreen(),
                                    ),
                                  ),
                                ),
                                scrollController: scrollController,
                              )
                            : OptimizedListView<Race>(
                                items: controller.filteredItems,
                                itemBuilder: (ctx, race, index) => RaceCardItem(
                                  key: ValueKey(race.key),
                                  race: race,
                                  onTap: () => _editRace(context, race),
                                  onLongPress: () => _showRaceContextMenu(
                                      race, context, controller, service),
                                  onShare: () =>
                                      service.exportToPdf(context, race),
                                  onSettings: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const SwipeActionSettingsScreen(),
                                    ),
                                  ),
                                ),
                                onReorder: (oldIndex, newIndex) =>
                                    controller.reorder(oldIndex, newIndex),
                                scrollController: scrollController,
                                enableReorder: !isSearching &&
                                    controller.selectedTag == null,
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            floatingActionButton: animatedFAB(
              CommonListFloatingButtons(
                onImport: () => _importRace(context, service),
                onAdd: () => _handleCreateRace(context),
                heroTag: "race_list",
              ),
              key: const ValueKey('race_fab'),
            ),
          );
        },
      ),
    );
  }
}
