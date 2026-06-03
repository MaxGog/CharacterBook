import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/data/models/template_model.dart';
import 'package:characterbook/data/repositories/template_repository.dart';
import 'package:characterbook/data/services/template_service.dart';
import 'package:characterbook/services/app_navigator.dart';
import 'package:characterbook/ui/controllers/template_list_controller.dart';
import 'package:characterbook/ui/screens/characters/character_management_screen.dart';
import 'package:characterbook/ui/screens/settings/swipe_action_settings_screen.dart';
import 'package:characterbook/ui/widgets/dialogs/share_options_dialog.dart';
import 'package:characterbook/ui/widgets/list/list_state_indicator.dart';
import 'package:characterbook/ui/widgets/items/template_card_item.dart';
import 'package:characterbook/ui/widgets/tools_context_menu.dart';
import 'package:characterbook/ui/widgets/common_fab_menu.dart';
import 'package:characterbook/ui/screens/templates/template_management_screen.dart';
import 'package:characterbook/ui/widgets/tag_filter.dart';
import 'package:characterbook/data/enums/template_sort_enum.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TemplatesListScreen extends StatefulWidget {
  const TemplatesListScreen({super.key});

  @override
  State<TemplatesListScreen> createState() => _TemplatesListScreenState();
}

class _TemplatesListScreenState extends State<TemplatesListScreen> {
  final TextEditingController _searchController = TextEditingController();

  bool _isSearching = false;
  bool _isImporting = false;
  bool _isFabVisible = true;
  bool _isTagsVisible = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeDefaultTemplates();
  }

  Future<void> _initializeDefaultTemplates() async {
    final repo = context.read<TemplateRepository>();
    await repo.initializeDefaultTemplates();
  }

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

  List<String> _getSortTags(BuildContext context) {
    final s = S.of(context);
    return [s.a_to_z, s.z_to_a, s.fields_asc, s.fields_desc];
  }

  void _onTagSelected(
      String? tag, BuildContext context, TemplateListController controller) {
    if (tag == null) {
      controller.setSelectedTag(null);
      return;
    }
    final s = S.of(context);
    if (tag == s.a_to_z) {
      controller.setSort(TemplateSort.nameAsc);
    } else if (tag == s.z_to_a) {
      controller.setSort(TemplateSort.nameDesc);
    } else if (tag == s.fields_asc) {
      controller.setSort(TemplateSort.fieldsAsc);
    } else if (tag == s.fields_desc) {
      controller.setSort(TemplateSort.fieldsDesc);
    } else {
      if (controller.selectedTag == tag) {
        controller.setSelectedTag(null);
      } else {
        controller.setSelectedTag(tag);
      }
    }
  }

  void _showTemplateContextMenu(QuestionnaireTemplate template,
      BuildContext context, TemplateListController controller) {
    final s = S.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ContextMenu.template(
        template: template,
        onEdit: () => _navigateToEdit(context, template),
        onDelete: () => _deleteTemplate(template, controller),
        onShare: () {
          ShareOptionsDialog.show(
            context,
            onCopy: () async {
              try {
                await controller.templateClipboardText(template, context);
                if (context.mounted) {
                  (
                    AppNavigator.showSuccess(s.copied_to_clipboard)
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  AppNavigator.showSuccess('${s.copy_error}: $e');
                }
              }
            },
            onShareFile: () async {
              try {
                await controller.shareTemplateAsFile(template);
              } catch (e) {
                if (context.mounted) {
                  AppNavigator.showSuccess('${s.error}: $e');
                }
              }
            },
            onExportWord: () async {
              try {
                await controller.exportTemplateToWord(template, context);
              } catch (e) {
                if (context.mounted) {
                  AppNavigator.showSuccess('${s.export_error}: $e');
                }
              }
            },
          );
        },
      ),
    );
  }

  Future<void> _deleteTemplate(
      QuestionnaireTemplate template, TemplateListController controller) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(context).template_delete_title),
        content: Text(S.of(context).template_delete_confirm),
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
      await controller.deleteTemplate(template);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).template_deleted)),
        );
      }
    }
  }

  void _navigateToDetail(QuestionnaireTemplate template) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TemplateDetailsModal(
        template: template,
        onCreateCharacter: () => _createCharacterFromTemplate(template),
      ),
    );
  }

  void _createCharacterFromTemplate(QuestionnaireTemplate template) async {
    Navigator.pop(context);
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CharacterManagementScreen(template: template),
      ),
    );
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                S.of(context).character_created_from_template(template.name))),
      );
    }
  }

  void _navigateToEdit(BuildContext context,
      [QuestionnaireTemplate? template]) {
    Navigator.push<bool>(
      context,
      MaterialPageRoute(
          builder: (_) => TemplateManagementScreen(template: template)),
    );
  }

  Future<void> _importTemplate(BuildContext context, TemplateService service,
      TemplateListController controller) async {
    setState(() {
      _isImporting = true;
      _errorMessage = null;
    });
    try {
      final template = await service.pickAndImportTemplate();
      if (template == null) {
        if (mounted) _showSnackBar(S.of(context).import_cancelled);
        return;
      }

      final existing = await service.getAllTemplates();
      final exists = existing.any((t) => t.name == template.name);
      if (exists) {
        final replace = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(S.of(context).template_exists),
            content:
                Text(S.of(context).template_replace_confirm(template.name)),
            actions: [
              TextButton(
                  child: Text(S.of(context).cancel),
                  onPressed: () => Navigator.pop(ctx, false)),
              TextButton(
                  child: Text(S.of(context).replace),
                  onPressed: () => Navigator.pop(ctx, true)),
            ],
          ),
        );
        if (replace != true) {
          if (mounted) _showSnackBar(S.of(context).import_cancelled);
          return;
        }
      }

      await service.saveTemplate(template);
      if (mounted)
        _showSnackBar(S.of(context).template_imported(template.name));
    } catch (e) {
      setState(() => _errorMessage = e.toString());
      if (mounted) _showSnackBar(S.of(context).import_error(e.toString()));
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TemplateListController>();
    final service = context.read<TemplateService>();
    final s = S.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final sortTags = _getSortTags(context);

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
              title: _isSearching ? null : Text(s.templates),
              actions: [
                if (!_isSearching) ...[
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _startSearch,
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
                      preferredSize: const Size.fromHeight(kToolbarHeight),
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
                  isLoading: _isImporting || controller.isLoading,
                  errorMessage: _errorMessage ?? controller.error,
                  onErrorClose: () => setState(() => _errorMessage = null),
                ),
              ),
              if (sortTags.isNotEmpty)
                SliverToBoxAdapter(
                  child: AnimatedCrossFade(
                    duration: const Duration(milliseconds: 300),
                    crossFadeState: _isTagsVisible
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: TagFilter(
                        tags: sortTags,
                        selectedTag: controller.selectedTag,
                        onTagSelected: (tag) =>
                            _onTagSelected(tag, context, controller),
                        context: context,
                      ),
                    ),
                    secondChild: const SizedBox.shrink(),
                  ),
                ),
              if (controller.filteredItems.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child:
                        Text(s.no_templates, style: theme.textTheme.bodyLarge),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final template = controller.filteredItems[index];
                      return TemplateCardItem(
                        key: ValueKey('${template.name}-$index'),
                        template: template,
                        isSelected: false,
                        onTap: () => _navigateToDetail(template),
                        onLongPress: () => _showTemplateContextMenu(
                            template, context, controller),
                        onMenuPressed: () => _showTemplateContextMenu(
                            template, context, controller),
                        onShare: () => service.shareTemplate(template),
                        onSettings: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SwipeActionSettingsScreen(),
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
                onImport: () => _importTemplate(context, service, controller),
                onAdd: () => _navigateToEdit(context),
                importTooltip: S.of(context).import_template_tooltip,
                addTooltip: S.of(context).create_template_tooltip,
                heroTag: "templates_list",
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}

class _TemplateDetailsModal extends StatelessWidget {
  final QuestionnaireTemplate template;
  final VoidCallback onCreateCharacter;

  const _TemplateDetailsModal({
    required this.template,
    required this.onCreateCharacter,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final s = S.of(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.library_books_rounded,
                            color: colorScheme.primary, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              template.name,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              s.fields_count(template.standardFields.length +
                                  template.customFields.length),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildFieldsSection(
                    context,
                    title: s.standard_fields,
                    fields: template.standardFields,
                    icon: Icons.check_circle_rounded,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 20),
                  if (template.customFields.isNotEmpty)
                    _buildFieldsSection(
                      context,
                      title: s.custom_fields,
                      fields: template.customFields.map((f) => f.key).toList(),
                      icon: Icons.add_circle_rounded,
                      color: colorScheme.tertiary,
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(s.cancel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: onCreateCharacter,
                  child: Text(s.create),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFieldsSection(
    BuildContext context, {
    required String title,
    required List<String> fields,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                fields.length.toString(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: fields.map((field) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                field,
                style: theme.textTheme.bodyMedium,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
