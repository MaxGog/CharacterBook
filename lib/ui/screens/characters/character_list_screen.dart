import 'package:characterbook/data/enums/character_sort_enum.dart';
import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/data/models/character_model.dart';
import 'package:characterbook/data/models/template_model.dart';
import 'package:characterbook/data/repositories/character_repository.dart';
import 'package:characterbook/data/services/character_service.dart';
import 'package:characterbook/ui/widgets/dialogs/share_options_dialog.dart';
import 'package:characterbook/ui/widgets/modals/character_modal_card.dart';
import 'package:characterbook/ui/controllers/character_list_controller.dart';
import 'package:characterbook/ui/screens/settings/swipe_action_settings_screen.dart';
import 'package:characterbook/ui/screens/templates/templates_list_screen.dart';
import 'package:characterbook/ui/widgets/appbar/common_main_app_bar.dart';
import 'package:characterbook/ui/widgets/buttons/common_fab_menu.dart';
import 'package:characterbook/ui/widgets/list/list_state_indicator.dart';
import 'package:characterbook/ui/widgets/list/optimized_list_view.dart';
import 'package:characterbook/ui/widgets/list/grouped_tag_list.dart';
import 'package:characterbook/ui/widgets/items/character_card_item.dart';
import 'package:characterbook/ui/widgets/tags/tag_filter.dart';
import 'package:characterbook/ui/widgets/tools_context_menu.dart';
import 'package:characterbook/ui/widgets/mixins/list_page_mixin.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'character_management_screen.dart';

class CharacterListScreen extends StatefulWidget {
  const CharacterListScreen({super.key});

  @override
  State<CharacterListScreen> createState() => _CharacterListScreenState();
}

class _CharacterListScreenState extends State<CharacterListScreen>
    with ListPageMixin<CharacterListScreen> {
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

  // Новый метод для переключения режима со сбросом выбранного тега
  void _toggleGroupMode(CharacterListController controller) {
    toggleGroupByTagMode();
    // В режиме папок фильтр по одному тегу не нужен
    controller.setSelectedTag(null);
  }

  Future<void> _importCharacter(
      BuildContext context, CharacterService service) async {
    setState(() {
      isImporting = true;
      errorMessage = null;
    });
    try {
      final character = await context
          .read<CharacterListController>()
          .importCharacter(() => filePickerService.importCharacter(), service);
      if (mounted && character != null) {
        showSnackBar(S.of(context).character_imported(character.name));
      }
    } catch (e) {
      setState(() => errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => isImporting = false);
    }
  }

  Future<void> _deleteCharacter(
      Character character, CharacterListController controller) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(context).character_delete_title),
        content: Text(S.of(context).character_delete_confirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(S.of(context).cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(S.of(context).delete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await controller.deleteCharacter(character);
      if (mounted) {
        showSnackBar(S.of(context).character_deleted);
      }
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
      builder: (ctx) => ContextMenu.character(
        character: character,
        onEdit: () => _navigateToEdit(context, character),
        onDelete: () => _deleteCharacter(character, controller),
        onDuplicate: () async {
          try {
            await controller.duplicateCharacter(character, service);
            if (context.mounted) {
              showSnackBar(s.character_duplicated);
            }
          } catch (e) {
            if (context.mounted) {
              showSnackBar('${s.duplicate_error}: $e');
            }
          }
        },
        onShare: () {
          ShareOptionsDialog.show(
            context,
            onCopy: () async {
              try {
                await controller.characterClipboardText(character, context);
                if (context.mounted) showSnackBar(s.copied_to_clipboard);
              } catch (e) {
                if (context.mounted) showSnackBar('${s.copy_error}: $e');
              }
            },
            onShareFile: () async {
              try {
                await controller.shareCharacterAsFile(character);
              } catch (e) {
                if (context.mounted) showSnackBar('${s.error}: $e');
              }
            },
            onExportPdf: () async {
              try {
                await controller.exportCharacterToPdf(character, context);
              } catch (e) {
                if (context.mounted) showSnackBar('${s.export_error}: $e');
              }
            },
          );
        },
      ),
    );
  }

  void _navigateToDetail(Character character) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CharacterModalCard(character: character),
    );
  }

  void _navigateToEdit(BuildContext context, [Character? character]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CharacterManagementScreen(character: character),
      ),
    );
  }

  Future<void> _createFromTemplate(BuildContext context) async {
    final template = await Navigator.push<QuestionnaireTemplate>(
      context,
      MaterialPageRoute(builder: (_) => const TemplatesListScreen()),
    );
    if (template != null && mounted) {
      _navigateToEdit(context, template.applyToCharacter(Character.empty()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CharacterListController(
        context.read<CharacterRepository>(),
      ),
      child: Consumer<CharacterListController>(
        builder: (context, controller, child) {
          final service = context.read<CharacterService>();
          final s = S.of(context);
          return Scaffold(
            appBar: CommonMainAppBar(
              title: s.my_characters,
              isSearching: isSearching,
              searchController: searchController,
              searchHint: s.search_characters,
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
              onTemplatesPressed: () => _createFromTemplate(context),
            ),
            body: Column(
              children: [
                ListStateIndicator(
                  isLoading: isImporting || controller.isLoading,
                  errorMessage: errorMessage ?? controller.error,
                  onErrorClose: () {
                    setState(() {
                      errorMessage = null;
                    });
                  },
                ),
                Expanded(
                  child: Column(
                    children: [
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
                        crossFadeState: (controller.allTags.isNotEmpty ||
                                    _getTags(context, controller).length > 4) &&
                                isTagsVisible
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                      ),
                      Expanded(
                        child: controller.filteredItems.isEmpty
                            ? Center(
                                child: Text(
                                  S.of(context).no_characters,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              )
                            : isGroupByTagMode
                                ? GroupedTagList<Character>(
                                    items: controller.filteredItems,
                                    getItemTags: (character) => character
                                        .tags, // или controller.getTags(character)
                                    itemBuilder: (ctx, character) =>
                                        CharacterCardItem(
                                      key: ValueKey(character.key),
                                      character: character,
                                      isSelected: false,
                                      onTap: () => _navigateToDetail(character),
                                      onLongPress: () =>
                                          _showCharacterContextMenu(character,
                                              context, controller, service),
                                      onEdit: () =>
                                          _navigateToEdit(context, character),
                                      onDelete: () => _deleteCharacter(
                                          character, controller),
                                      onDuplicate: () =>
                                          service.duplicateCharacter(character),
                                      onSettings: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const SwipeActionSettingsScreen(),
                                        ),
                                      ),
                                      onShare: () => service.exportToPdf(
                                          context, character),
                                    ),
                                    scrollController: scrollController,
                                  )
                                : OptimizedListView<Character>(
                                    items: controller.filteredItems,
                                    itemBuilder: (ctx, character, index) =>
                                        CharacterCardItem(
                                      key: ValueKey(character.key),
                                      character: character,
                                      isSelected: false,
                                      onTap: () => _navigateToDetail(character),
                                      onLongPress: () =>
                                          _showCharacterContextMenu(character,
                                              context, controller, service),
                                      onEdit: () =>
                                          _navigateToEdit(context, character),
                                      onDelete: () => _deleteCharacter(
                                          character, controller),
                                      onDuplicate: () =>
                                          service.duplicateCharacter(character),
                                      onSettings: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const SwipeActionSettingsScreen(),
                                        ),
                                      ),
                                      onShare: () => service.exportToPdf(
                                          context, character),
                                    ),
                                    onReorder: (oldIndex, newIndex) =>
                                        controller.reorder(oldIndex, newIndex),
                                    scrollController: scrollController,
                                  ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            floatingActionButton: Visibility(
              visible: isFabVisible,
              child: animatedFAB(
                CommonListFloatingButtons(
                  onImport: () => _importCharacter(context, service),
                  onAdd: () => _navigateToEdit(context),
                  onTemplate: () => _createFromTemplate(context),
                  heroTag: "character_list",
                ),
                key: const ValueKey('character_fab'),
              ),
            ),
          );
        },
      ),
    );
  }
}
