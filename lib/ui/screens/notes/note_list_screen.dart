import 'package:characterbook/data/enums/note_sort_enum.dart';
import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/data/models/note_model.dart';
import 'package:characterbook/data/repositories/note_repository.dart';
import 'package:characterbook/ui/controllers/note_list_controller.dart';
import 'package:characterbook/ui/navigation/menu_content.dart';
import 'package:characterbook/ui/widgets/common_fab_menu.dart';
import 'package:characterbook/ui/widgets/dialogs/share_options_dialog.dart';
import 'package:characterbook/ui/widgets/items/note_card_item.dart';
import 'package:characterbook/ui/widgets/list/list_state_indicator.dart';
import 'package:characterbook/ui/widgets/empty_notes_state.dart';
import 'package:characterbook/ui/widgets/tag_filter.dart';
import 'package:characterbook/ui/widgets/tools_context_menu.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'note_management_screen.dart';

class _NoteGroup {
  final String tag;
  final List<Note> notes;
  const _NoteGroup({required this.tag, required this.notes});
}

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final TextEditingController _searchController = TextEditingController();

  bool _isSearching = false;
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

  void _toggleGroupMode(NoteListController controller) {
    setState(() => _isGroupByTagMode = !_isGroupByTagMode);
    controller.setSelectedTag(null);
    if (_isGroupByTagMode) {
      _expandedGroups.clear();
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _deleteNote(Note note, NoteListController controller) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(context).template_delete_title),
        content: Text(
            '${S.of(context).posts} "${note.title}" ${S.of(context).template_delete_confirm}'),
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
      await controller.deleteNote(note);
      if (mounted) {
        _showSnackBar(
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
                if (context.mounted) _showSnackBar(s.copied_to_clipboard);
              } catch (e) {
                if (context.mounted) _showSnackBar('${s.copy_error}: $e');
              }
            },
            onShareFile: () async {
              try {
                await controller.shareNoteAsFile(note);
              } catch (e) {
                if (context.mounted) _showSnackBar('${s.error}: $e');
              }
            },
          );
        },
      ),
    );
  }

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

  List<_NoteGroup> _buildNoteGroups(List<Note> notes) {
    final Map<String, List<Note>> groups = {};
    final List<Note> noTag = [];

    for (final note in notes) {
      if (note.tags.isEmpty) {
        noTag.add(note);
        continue;
      }
      for (final tag in note.tags) {
        groups.putIfAbsent(tag, () => []).add(note);
      }
    }

    final List<_NoteGroup> result = [];
    final sortedTags = groups.keys.toList()..sort();
    for (final tag in sortedTags) {
      result.add(_NoteGroup(tag: tag, notes: groups[tag]!));
    }
    if (noTag.isNotEmpty) {
      result
          .add(_NoteGroup(tag: S.of(context).no_folder_selected, notes: noTag));
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

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NoteListController(context.read<NoteRepository>()),
      child: Consumer<NoteListController>(
        builder: (context, controller, child) {
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
                    title: _isSearching
                        ? null
                        : Text('${s.my} ${s.posts.toLowerCase()}'),
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
                                hintText: s.search_hint,
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
                        isLoading: controller.isLoading,
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
                        child: controller.selectedTag == null && !_isSearching
                            ? NotesEmptyState(isSearching: false)
                            : NotesEmptyState(
                                isSearching: _isSearching &&
                                    _searchController.text.isNotEmpty),
                      )
                    else if (_isGroupByTagMode)
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final groups =
                                _buildNoteGroups(controller.filteredItems);
                            if (index >= groups.length) return null;
                            final group = groups[index];
                            final isExpanded =
                                _expandedGroups[group.tag] ?? true;

                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildGroupHeader(
                                    group.tag, isExpanded, group.notes.length),
                                AnimatedSize(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                  child: isExpanded
                                      ? Column(
                                          children: group.notes
                                              .map((note) => NoteCardItem(
                                                    key: ValueKey(note.key),
                                                    note: note,
                                                    onTap: () =>
                                                        _handleNoteTap(note),
                                                    onEdit: () =>
                                                        _editNote(note),
                                                    onLongPress: () =>
                                                        _showNoteContextMenu(
                                                            note, controller),
                                                    onDelete: () => _deleteNote(
                                                        note, controller),
                                                  ))
                                              .toList(),
                                        )
                                      : const SizedBox.shrink(),
                                ),
                              ],
                            );
                          },
                          childCount:
                              _buildNoteGroups(controller.filteredItems).length,
                        ),
                      )
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final note = controller.filteredItems[index];
                            return NoteCardItem(
                              key: ValueKey(note.key),
                              note: note,
                              onTap: () => _handleNoteTap(note),
                              onEdit: () => _editNote(note),
                              onLongPress: () =>
                                  _showNoteContextMenu(note, controller),
                              onDelete: () => _deleteNote(note, controller),
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
                      showImportButton: false,
                      onAdd: _openNoteCreation,
                      heroTag: "note_list",
                    )
                  : const SizedBox.shrink(),
            ),
          );
        },
      ),
    );
  }
}
