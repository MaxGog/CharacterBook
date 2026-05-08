import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/data/models/character_model.dart';
import 'package:characterbook/data/models/race_model.dart';
import 'package:characterbook/data/services/character_service.dart';
import 'package:characterbook/data/services/race_service.dart';
import 'package:characterbook/services/clipboard_service.dart';
import 'package:characterbook/services/date_formatter.dart';
import 'package:characterbook/services/pdf_export_manager.dart';
import 'package:characterbook/ui/controllers/home_controller.dart';
import 'package:characterbook/ui/widgets/dialogs/share_options_dialog.dart';
import 'package:characterbook/ui/widgets/modals/character_modal_card.dart';
import 'package:characterbook/ui/widgets/modals/race_modal_card.dart';
import 'package:characterbook/ui/navigation/menu_content.dart';
import 'package:characterbook/ui/screens/characters/character_management_screen.dart';
import 'package:characterbook/ui/screens/notes/note_management_screen.dart';
import 'package:characterbook/ui/screens/races/race_management_screen.dart';
import 'package:characterbook/ui/widgets/home_fab_menu.dart';
import 'package:characterbook/ui/widgets/items/character_keep_card_item.dart';
import 'package:characterbook/ui/widgets/items/home_item.dart';
import 'package:characterbook/ui/widgets/items/race_keep_card_item.dart';
import 'package:characterbook/ui/widgets/items/tool_keep_card_item.dart';
import 'package:characterbook/ui/widgets/pinned_section.dart';
import 'package:characterbook/ui/widgets/tools_context_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeController _controller;
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  bool _isSearching = false;
  FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    final characterService = context.read<CharacterService>();
    final raceService = context.read<RaceService>();
    _controller = HomeController(
      characterService: characterService,
      raceService: raceService,
    );
    _loadData();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _controller.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
      _searchController.clear();
      _controller.setSearchQuery('');
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_searchFocus);
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
    });
    _searchController.clear();
    _controller.setSearchQuery('');
    _searchFocus.unfocus();
    _searchDebounce?.cancel();
  }

  Future<void> _loadData() async {
    try {
      await _controller.loadData();
      if (mounted) setState(() {});
    } catch (e, stackTrace) {
      debugPrint('Error loading home data: $e\n$stackTrace');
    }
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        _controller.setSearchQuery(query);
      }
    });
  }

  void _onSearchSubmitted(String query) {
    _searchDebounce?.cancel();
    _controller.setSearchQuery(query);
  }

  void _navigateToTool(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
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
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
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
                  child: MenuContent(
                    scrollController: scrollController,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showCharacterDetail(CharacterHomeItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CharacterModalCard(character: item.character),
    );
  }

  void _showCharacterContextMenu(CharacterHomeItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ContextMenu.character(
        character: item.character,
        onEdit: () {
          _editCharacter(item.character);
        },
        onDelete: () {
          _showDeleteDialog(item);
        },
        onDuplicate: () {
          _duplicateCharacter(item);
        },
        onShare: () {
          _showCharacterShareOptions(item);
        },
      ),
    );
  }

  void _showRaceContextMenu(RaceHomeItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ContextMenu.race(
        race: item.race,
        onEdit: () {
          _editRace(item.race);
        },
        onDelete: () {
          _showDeleteDialog(item);
        },
        onShare: () {
          _showRaceShareOptions(item);
        },
      ),
    );
  }

  Future<void> _duplicateCharacter(CharacterHomeItem item) async {
    try {
      final newChar = item.character.copyWith(
        id: null,
        name: '${item.character.name} (копия)',
      );
      final characterService = context.read<CharacterService>();
      await characterService.saveCharacter(newChar);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).character_duplicated)),
        );
        await _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.of(context).duplicate_error}: $e')),
        );
      }
    }
  }

  Future<void> _showCharacterShareOptions(CharacterHomeItem item) async {
    final s = S.of(context);
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(s.share),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.copy),
                title: Text(s.copy_character),
                onTap: () async {
                  Navigator.pop(dialogContext);
                  try {
                    await ClipboardService.copyCharacterToClipboard(
                      context: context,
                      name: item.character.name,
                      age: item.character.age,
                      gender: item.character.gender,
                      raceName: item.character.race?.name,
                      biography: item.character.biography,
                      appearance: item.character.appearance,
                      personality: item.character.personality,
                      abilities: item.character.abilities,
                      other: item.character.other,
                      customFields: item.character.customFields
                          .map((f) => {'key': f.key, 'value': f.value})
                          .toList(),
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(s.copied_to_clipboard)),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${s.copy_error}: $e')),
                      );
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.file_upload),
                title: Text(s.file_character),
                onTap: () async {
                  Navigator.pop(dialogContext);
                  try {
                    final content = jsonEncode(item.character.toJson());
                    final tempDir = await getTemporaryDirectory();
                    final file = File(
                        '${tempDir.path}/${item.character.name}.character');
                    await file.writeAsString(content);
                    await Share.shareXFiles(
                      [XFile(file.path)],
                      text: '${item.character.name}',
                    );
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${s.error}: $e')),
                      );
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: Text(s.file_pdf),
                onTap: () async {
                  Navigator.pop(dialogContext);
                  try {
                    await PdfExportManager.exportCharacterWithDialog(
                        context, item.character);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${s.export_error}: $e')),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRaceShareOptions(RaceHomeItem item) {
    final s = S.of(context);
    ShareOptionsDialog.show(
      context,
      onCopy: () async {
        try {
          final buffer = StringBuffer();
          buffer.writeln(item.race.name);
          if (item.race.description.isNotEmpty) {
            buffer.writeln(item.race.description);
          }
          await Clipboard.setData(ClipboardData(text: buffer.toString()));
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(s.copied_to_clipboard)),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${s.copy_error}: $e')),
            );
          }
        }
      },
      onShareFile: () async {
        try {
          final content = jsonEncode(item.race.toJson());
          final tempDir = await getTemporaryDirectory();
          final file = File('${tempDir.path}/${item.race.name}.race');
          await file.writeAsString(content);
          await Share.shareXFiles(
            [XFile(file.path)],
            text: '${item.race.name}',
          );
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${s.error}: $e')),
            );
          }
        }
      },
      onExportPdf: () async {
        try {
          if (context.mounted) {
            await PdfExportManager.exportRaceWithDialog(context, item.race);
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${s.export_error}: $e')),
            );
          }
        }
      },
    );
  }

  Future<void> _editCharacter(Character character) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CharacterManagementScreen(character: character),
      ),
    );
    if (result == true && mounted) await _loadData();
  }

  Future<void> _editRace(Race race) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RaceManagementScreen(race: race),
      ),
    );
    if (result == true && mounted) await _loadData();
  }

  Future<void> _showDeleteDialog(HomeItem item) async {
    final s = S.of(context);
    final isCharacter = item is CharacterHomeItem;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text(isCharacter ? s.character_delete_title : s.race_delete_title),
        content: Text(
          isCharacter ? s.character_delete_confirm : s.race_delete_confirm,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(s.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              s.delete,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _controller.deleteItem(item);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isCharacter ? s.character_deleted : s.race_deleted,
            ),
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error deleting item: $e\n$stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${s.delete_error}: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showRaceDetail(RaceHomeItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RaceModalCard(race: item.race),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double minExtent = kToolbarHeight + statusBarHeight;
    final double maxExtent = minExtent + 80;   
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: () => _controller.loadData(),
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              if (!_isSearching)
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _HomeAppBarDelegate(
                    leading: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Image.asset(
                          'assets/iconapp.png',
                          height: 24,
                          width: 24,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.book_rounded, size: 32),
                        ),
                      ),
                    ),
                    searchBar: _buildSearchBar(context),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.account_circle_rounded),
                        iconSize: 32,
                        onPressed: _showAccountMenu,
                        tooltip: S.of(context).more_options,
                      ),
                    ],
                    onSearchTap: _startSearch,
                    minExtent: minExtent,
                    maxExtent: maxExtent,
                  ),
                )
              else
                SliverAppBar(
                  pinned: true,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: _stopSearch,
                  ),
                  title: TextField(
                    controller: _searchController,
                    focusNode: _searchFocus,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: S.of(context).search,
                      border: InputBorder.none,
                    ),
                    onChanged: _onSearchChanged,
                    onSubmitted: _onSearchSubmitted,
                    textInputAction: TextInputAction.search,
                  ),
                  actions: [
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _controller.setSearchQuery('');
                        },
                      ),
                  ],
                ),
            ],
            body: Consumer<HomeController>(
              builder: (context, controller, _) {
                if (controller.searchQuery.isNotEmpty) {
                  return _SearchResultsGrid(
                    items: controller.filteredItems,
                    onCharacterTap: _showCharacterDetail,
                    onCharacterContextMenu: _showCharacterContextMenu,
                    onRaceTap: _showRaceDetail,
                    onRaceContextMenu: _showRaceContextMenu,
                    onToolTap: (tool) => _navigateToTool(tool.page),
                  );
                }

                if (!controller.hasItems) {
                  return _EmptyState(
                    isSearching: false,
                    onCreateNew: _createNewContent,
                  );
                }

                return _MainExpressiveContent(
                  controller: controller,
                  onCharacterTap: _showCharacterDetail,
                  onCharacterContextMenu: _showCharacterContextMenu,
                  onRaceTap: _showRaceDetail,
                  onRaceContextMenu: _showRaceContextMenu,
                  onToolTap: _navigateToTool,
                );
              },
            ),
          ),
        ),
        floatingActionButton: HomeFloatingMenu(
          onCreateCharacter: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const CharacterManagementScreen()),
            ).then((result) {
              if (result == true && mounted) _loadData();
            });
          },
          onCreateRace: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RaceManagementScreen()),
            ).then((result) {
              if (result == true && mounted) _loadData();
            });
          },
          onCreateNote: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NoteManagementScreen()),
            ).then((result) {
              if (result == true && mounted) _loadData();
            });
          },
        ),
      ),
    );
  }

  void _createNewContent() {
    // FAB уже обрабатывает создание
  }

  Widget _buildSearchBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final s = S.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SearchBar(
        controller: _searchController,
        hintText: s.app_name,
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 16),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        backgroundColor:
            WidgetStatePropertyAll(colorScheme.surfaceContainerHigh),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(0),
        onChanged: _onSearchChanged,
        onSubmitted: _onSearchSubmitted,
        textStyle: WidgetStatePropertyAll(
          TextStyle(color: colorScheme.onSurface),
        ),
        hintStyle: WidgetStatePropertyAll(
          TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _HomeAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget leading;
  final Widget searchBar;
  final List<Widget> actions;
  final VoidCallback onSearchTap;

  _HomeAppBarDelegate({
    required this.leading,
    required this.searchBar,
    required this.actions,
    required this.onSearchTap,
    required this.minExtent,
    required this.maxExtent,
  });

  @override
  final double minExtent;

  @override
  final double maxExtent;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final double maxScrollExtent = maxExtent - minExtent;
    final double progress = (shrinkOffset / maxScrollExtent).clamp(0.0, 1.0);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final double paddingTop = MediaQuery.of(context).padding.top;

    const double searchBarTotalHeight = 76.0;

    return Container(
      color: colorScheme.surface,
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: minExtent - paddingTop,
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: leading,
              actions: [
                AnimatedOpacity(
                  opacity: progress,
                  duration: const Duration(milliseconds: 200),
                  child: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: onSearchTap,
                  ),
                ),
                ...actions,
              ],
            ),
          ),
          Positioned(
            bottom: minExtent - paddingTop,
            left: 0,
            right: 0,
            child: Transform.translate(
              offset: Offset(0, -progress * searchBarTotalHeight),
              child: Opacity(
                opacity: 1 - progress,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: searchBar,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_HomeAppBarDelegate oldDelegate) => true;
}

class _SearchResultsGrid extends StatelessWidget {
  const _SearchResultsGrid({
    required this.items,
    required this.onCharacterTap,
    required this.onCharacterContextMenu,
    required this.onRaceTap,
    required this.onRaceContextMenu,
    required this.onToolTap,
  });

  final List<HomeItem> items;
  final void Function(CharacterHomeItem) onCharacterTap;
  final void Function(CharacterHomeItem) onCharacterContextMenu;
  final void Function(RaceHomeItem) onRaceTap;
  final void Function(RaceHomeItem) onRaceContextMenu;
  final void Function(ToolHomeItem) onToolTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _EmptyState(isSearching: true, onCreateNew: null);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = (constraints.maxWidth / 180).floor().clamp(2, 5);
        return GridView.builder(
          padding: const EdgeInsets.all(4),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
            childAspectRatio: 1,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return switch (item) {
              CharacterHomeItem(:final character) => CharacterKeepCardItem(
                  character: character,
                  onTap: () => onCharacterTap(item),
                  onContextMenuTap: () => onCharacterContextMenu(item),
                  formattedDate: character.lastEdited.toRelativeString(context),
                ),
              RaceHomeItem(:final race) => RaceKeepCardItem(
                  race: race,
                  characterCount: 0,
                  onTap: () => onRaceTap(item),
                  onContextMenuTap: () => onRaceContextMenu(item),
                ),
              ToolHomeItem() => ToolKeepCardItem(
                  title: item.getTitle(context),
                  subtitle: item.getSubtitle(context),
                  icon: item.getIcon(),
                  iconColor: Theme.of(context).colorScheme.primary,
                  onTap: () => onToolTap(item),
                ),
            };
          },
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isSearching, required this.onCreateNew});
  final bool isSearching;
  final VoidCallback? onCreateNew;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline_rounded,
              size: 64,
              color: colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              isSearching ? s.nothing_found : s.no_content_home,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            if (!isSearching) ...[
              const SizedBox(height: 8),
              Text(
                s.create_first_content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: onCreateNew,
                child: Text(s.create),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MainExpressiveContent extends StatelessWidget {
  const _MainExpressiveContent({
    required this.controller,
    required this.onCharacterTap,
    required this.onCharacterContextMenu,
    required this.onRaceTap,
    required this.onRaceContextMenu,
    required this.onToolTap,
  });

  final HomeController controller;
  final void Function(CharacterHomeItem) onCharacterTap;
  final void Function(CharacterHomeItem) onCharacterContextMenu;
  final void Function(RaceHomeItem) onRaceTap;
  final void Function(RaceHomeItem) onRaceContextMenu;
  final void Function(Widget) onToolTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: PinnedSection(
            items: controller.pinnedItems,
            allCharactersAndRaces: [
              ...controller.characters,
              ...controller.races,
            ],
            controller: controller,
            onCharacterTap: onCharacterTap,
            onCharacterContextMenu: onCharacterContextMenu,
            onRaceTap: onRaceTap,
            onRaceContextMenu: onRaceContextMenu,
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Icon(Icons.handyman_outlined,
                    size: 20, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  S.of(context).dnd_tools,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final tool = controller.tools[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _ToolMaterialCard(
                    tool: tool,
                    onTap: () => onToolTap(tool.page),
                  ),
                );
              },
              childCount: controller.tools.length,
            ),
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
      ],
    );
  }
}

class _ToolMaterialCard extends StatelessWidget {
  const _ToolMaterialCard({
    required this.tool,
    required this.onTap,
  });

  final ToolHomeItem tool;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      borderRadius: BorderRadius.circular(16),
      color: colorScheme.surfaceContainerHighest,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(
                tool.getIcon(),
                size: 32,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tool.getTitle(context),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

