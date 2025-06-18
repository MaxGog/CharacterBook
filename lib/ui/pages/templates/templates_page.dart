import 'package:characterbook/ui/pages/characters/character_management_page.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:characterbook/models/template_model.dart';
import 'package:characterbook/services/template_service.dart';
import 'package:characterbook/ui/widgets/context_menu.dart';
import 'package:characterbook/ui/widgets/custom_app_bar.dart';
import 'package:characterbook/ui/widgets/custom_floating_buttons.dart';
import 'package:characterbook/ui/pages/templates/template_edit_page.dart';
import '../../../generated/l10n.dart';

class TemplatesPage extends StatefulWidget {
  const TemplatesPage({super.key});

  @override
  State<TemplatesPage> createState() => _TemplatesPageState();
}

class _TemplatesPageState extends State<TemplatesPage> {
  final TemplateService _templateService = TemplateService();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _isImporting = false;
  String? _errorMessage;
  String _searchQuery = '';
  QuestionnaireTemplate? _selectedTemplate;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refreshTemplates() {
    setState(() {});
  }

  Future<void> _deleteTemplate(String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).template_delete_title),
        content: Text(S.of(context).template_delete_confirm),
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
      await _templateService.deleteTemplate(name);
      if (mounted) _showSnackBar(S.of(context).template_deleted);
      _refreshTemplates();
    }
  }

  Future<void> _importTemplate() async {
    try {
      setState(() {
        _isImporting = true;
        _errorMessage = null;
      });

      final template = await _templateService.pickAndImportTemplate();

      if (template != null) {
        final box = Hive.box<QuestionnaireTemplate>('templates');
        if (box.containsKey(template.name)) {
          final shouldReplace = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(S.of(context).template_exists),
              content: Text(S.of(context).template_replace_confirm(template.name)),
              actions: [
                TextButton(
                  child: Text(S.of(context).cancel),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: Text(S.of(context).replace),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            ),
          );

          if (shouldReplace != true) {
            if (mounted) _showSnackBar(S.of(context).import_cancelled);
            return;
          }
        }

        await box.put(template.name, template);
        if (mounted) _showSnackBar(S.of(context).template_imported(template.name));
        _refreshTemplates();
      } else {
        if (mounted) _showSnackBar(S.of(context).import_cancelled);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      if (mounted) _showSnackBar(S.of(context).import_error(e.toString()));
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

  void _showTemplateContextMenu(QuestionnaireTemplate template, BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ContextMenu(
        item: template,
        onEdit: () => _editTemplate(template),
        onDelete: () => _deleteTemplate(template.name),
        showExportPdf: false,
        showCopy: false,
      ),
    );
  }

  Future<void> _editTemplate(QuestionnaireTemplate template) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => TemplateEditPage(template: template),
      ),
    );
    if (result == true && mounted) {
      _refreshTemplates();
    }
  }

  Future<void> _createCharacterFromTemplate(QuestionnaireTemplate template) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CharacterEditPage(template: template),
      ),
    );

    if (result == true && mounted) {
      _showSnackBar(S.of(context).character_created_from_template(template.name));
    }
  }

  List<QuestionnaireTemplate> _filterTemplates(List<QuestionnaireTemplate> templates) {
    if (_searchQuery.isEmpty) return templates;
    return templates.where((template) =>
    template.name.toLowerCase().contains(_searchQuery) ||
        template.standardFields.any((field) => field.toLowerCase().contains(_searchQuery)) ||
        template.customFields.any((field) =>
        field.key.toLowerCase().contains(_searchQuery) ||
            field.value.toLowerCase().contains(_searchQuery))
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWideScreen = MediaQuery.of(context).size.width > 1000;

    return Scaffold(
      appBar: CustomAppBar(
        title: S.of(context).templates,
        isSearching: _isSearching,
        searchController: _searchController,
        searchHint: S.of(context).search,
        onSearchToggle: () => setState(() {
          _isSearching = !_isSearching;
          if (!_isSearching) {
            _searchController.clear();
            _searchQuery = '';
          }
        }),
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
            child: ValueListenableBuilder<Box<QuestionnaireTemplate>>(
              valueListenable: Hive.box<QuestionnaireTemplate>('templates').listenable(),
              builder: (context, box, _) {
                final allTemplates = box.values.toList().cast<QuestionnaireTemplate>();
                final templates = _filterTemplates(allTemplates);

                return isWideScreen
                    ? _buildWideLayout(templates, theme)
                    : _buildMobileLayout(templates, theme);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: CustomFloatingButtons(
        onImport: _importTemplate,
        onAdd: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TemplateEditPage(onSaved: _refreshTemplates),
          ),
        ),
        importTooltip: S.of(context).import_template_tooltip,
        addTooltip: S.of(context).create_template_tooltip,
        templateTooltip: S.of(context).create_from_template_tooltip,
      ),
    );
  }

  Widget _buildWideLayout(List<QuestionnaireTemplate> templates, ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 400,
          decoration: BoxDecoration(
            border: Border(right: BorderSide(color: theme.dividerColor)),
          ),
          child: _buildTemplatesList(templates, theme),
        ),
        Expanded(
          child: _selectedTemplate != null
              ? _buildTemplateDetails(_selectedTemplate!, theme)
              : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.library_books_outlined,
                  size: 48,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  S.of(context).select_template,
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(List<QuestionnaireTemplate> templates, ThemeData theme) {
    return _buildTemplatesList(templates, theme);
  }

  Widget _buildTemplateCard(QuestionnaireTemplate template, ThemeData theme) {
    final isSelected = _selectedTemplate?.name == template.name;

    return Card(
      key: ValueKey(template.name),
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
            setState(() => _selectedTemplate = template);
          } else {
            _createCharacterFromTemplate(template);
          }
        },
        onLongPress: () => _showTemplateContextMenu(template, context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.library_books,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(template.name, style: theme.textTheme.bodyLarge),
                    Text(
                      S.of(context).fields_count(template.standardFields.length + template.customFields.length),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.more_vert, color: theme.colorScheme.onSurfaceVariant),
                onPressed: () => _showTemplateContextMenu(template, context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemplatesList(List<QuestionnaireTemplate> templates, ThemeData theme) {
    if (templates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_books_outlined,
              size: 48,
              color: theme.colorScheme.onSurface,
            ),
            const SizedBox(height: 16),
            Text(
              _isSearching && _searchController.text.isNotEmpty
                  ? S.of(context).templates_not_found
                  : S.of(context).no_templates,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            if (!_isSearching)
              TextButton(
                onPressed: _importTemplate,
                child: Text(S.of(context).import_template),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: templates.length,
      itemBuilder: (context, index) => _buildTemplateCard(templates[index], theme),
    );
  }

  Widget _buildTemplateDetails(QuestionnaireTemplate template, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            template.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            S.of(context).standard_fields,
            style: theme.textTheme.titleMedium,
          ),
          ...template.standardFields.map((field) => ListTile(
            title: Text(field),
            leading: const Icon(Icons.check_box_outlined),
          )),
          if (template.customFields.isNotEmpty) ...[
            Text(
              S.of(context).custom_fields,
              style: theme.textTheme.titleMedium,
            ),
            ...template.customFields.map((field) => ListTile(
              title: Text(field.key),
              subtitle: field.value.isNotEmpty ? Text(field.value) : null,
              leading: const Icon(Icons.add_box_outlined),
            )),
          ],
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(S.of(context).back),
              ),
              const SizedBox(width: 16),
              FilledButton(
                onPressed: () => _createCharacterFromTemplate(template),
                child: Text(S.of(context).create_character),
              ),
            ],
          ),
        ],
      ),
    );
  }
}