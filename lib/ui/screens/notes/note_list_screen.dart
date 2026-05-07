import 'package:characterbook/data/enums/note_sort_enum.dart';
import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/data/models/note_model.dart';
import 'package:characterbook/data/repositories/note_repository.dart';
import 'package:characterbook/ui/controllers/note_list_controller.dart';
import 'package:characterbook/ui/widgets/appbar/common_main_app_bar.dart';
import 'package:characterbook/ui/widgets/buttons/common_fab_menu.dart';
import 'package:characterbook/ui/widgets/dialogs/share_options_dialog.dart';
import 'package:characterbook/ui/widgets/items/note_card_item.dart';
import 'package:characterbook/ui/widgets/list/list_state_indicator.dart';
import 'package:characterbook/ui/widgets/list/optimized_list_view.dart';
import 'package:characterbook/ui/widgets/states/empty_notes_state.dart';
import 'package:characterbook/ui/widgets/tags/tag_filter.dart';
import 'package:characterbook/ui/widgets/mixins/list_page_mixin.dart';
import 'package:characterbook/ui/widgets/tools_context_menu.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'note_management_screen.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen>
    with ListPageMixin<NotesListScreen> {

  List<String> _getTags(BuildContext context, NoteListController controller) {
    final s = S.of(context);
    return [
      s.a_to_z,
      s.z_to_a,
      ...controller.allTags,
    ];
  }

  void _onTagSelected(
      String? tag, BuildContext context, NoteListController controller) {
    if (tag == null) {
      controller.setSelectedTag(null);
      return;
    }

    final s = S.of(context);
    if (tag == s.a_to_z) {
      controller.setSort(NoteSort.titleAsc);
    } else if (tag == s.z_to_a) {
      controller.setSort(NoteSort.titleDesc);
    } else {
      if (controller.selectedTag == tag) {
        controller.setSelectedTag(null);
      } else {
        controller.setSelectedTag(tag);
      }
    }
  }

  Future<void> _deleteNote(Note note, NoteListController controller) async {
    final confirmed = await showDeleteConfirmationDialog(
      S.of(context).template_delete_title,
      '${S.of(context).posts} "${note.title}" ${S.of(context).template_delete_confirm}',
    );
    if (confirmed) {
      await controller.deleteNote(note);
      if (mounted) {
        showSnackBar(
            '${S.of(context).posts} "${note.title}" ${S.of(context).template_deleted}');
      }
    }
  }

  void _editNote(Note note) {
    Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => NoteManagementScreen(note: note)),
    );
  }

  void _handleNoteTap(Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteManagementScreen(note: note)),
    );
  }

  void _openNoteCreation() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NoteManagementScreen()),
    );
  }

  void _showNoteContextMenu(Note note, NoteListController controller) {
    final s = S.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ContextMenu.note(
        note: note,
        onEdit: () => _editNote(note),
        onDelete: () => _deleteNote(note, controller),
        onShare: () {
          ShareOptionsDialog.show(
            context,
            onCopy: () async {
              try {
                await controller.noteClipboardText(note, context);
                if (context.mounted) showSnackBar(s.copied_to_clipboard);
              } catch (e) {
                if (context.mounted) showSnackBar('${s.copy_error}: $e');
              }
            },
            onShareFile: () async {
              try {
                await controller.shareNoteAsFile(note);
              } catch (e) {
                if (context.mounted) showSnackBar('${s.error}: $e');
              }
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NoteListController(
        context.read<NoteRepository>(),
      ),
      child: Consumer<NoteListController>(
        builder: (context, controller, child) {
          final s = S.of(context);
          return Scaffold(
            appBar: CommonMainAppBar(
              title: '${s.my} ${s.posts.toLowerCase()}',
              isSearching: isSearching,
              searchController: searchController,
              searchHint: s.search_hint,
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
                    isLoading: controller.isLoading,
                    errorMessage: errorMessage ?? controller.error,
                    onErrorClose: () {
                      setState(() => errorMessage = null);
                    },
                  ),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final tags = _getTags(context, controller);
                        final notesToShow = controller.filteredItems;

                        if (notesToShow.isEmpty &&
                            !isSearching &&
                            controller.selectedTag == null) {
                          return NotesEmptyState(isSearching: false);
                        }

                        return Column(
                          children: [
                            if (tags.isNotEmpty)
                              AnimatedCrossFade(
                                duration: Duration(milliseconds: 300),
                                reverseDuration: Duration(milliseconds: 300),
                                firstCurve: Curves.easeInOutCubic,
                                secondCurve: Curves.easeInOutCubic,
                                firstChild: SizedBox(
                                  height: 40,
                                  child: TagFilter(
                                    tags: tags,
                                    selectedTag: controller.selectedTag,
                                    onTagSelected: (tag) => _onTagSelected(
                                        tag, context, controller),
                                    context: context,
                                  ),
                                ),
                                secondChild: const SizedBox.shrink(),
                                crossFadeState: isTagsVisible
                                    ? CrossFadeState.showFirst
                                    : CrossFadeState.showSecond,
                              ),
                            Expanded(
                              child: notesToShow.isEmpty
                                  ? NotesEmptyState(
                                      isSearching: isSearching &&
                                          searchController.text.isNotEmpty,
                                    )
                                  : OptimizedListView<Note>(
                                      items: notesToShow,
                                      itemBuilder: (ctx, note, index) =>
                                          NoteCardItem(
                                            key: ValueKey(note.key),
                                            note: note,
                                            onTap: () => _handleNoteTap(note),
                                            onEdit: () => _editNote(note),
                                            onLongPress: () => _showNoteContextMenu(note, controller),
                                            onDelete: () =>_deleteNote(note, controller),
                                          ),
                                      onReorder: (oldIndex, newIndex) =>
                                          controller.reorder(
                                              oldIndex, newIndex),
                                      scrollController: scrollController,
                                      enableReorder: !isSearching &&
                                          controller.selectedTag == null,
                                    ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            floatingActionButton: animatedFAB(
              CommonListFloatingButtons(
                  showImportButton: false,
                  onAdd: _openNoteCreation,
                  heroTag: "note_list",
              ), 
              key: const ValueKey('note_fab')
            )
          );
        },
      ),
    );
  }
}
