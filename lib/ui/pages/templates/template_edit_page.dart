import 'package:flutter/material.dart';
import 'package:characterbook/models/template_model.dart';
import 'package:characterbook/services/template_service.dart';
import '../../../generated/l10n.dart';
import '../../../models/custom_field_model.dart';
import '../../widgets/fields/custom_fields_editor.dart';
import '../../widgets/fields/custom_text_field.dart';
import '../../widgets/unsaved_changes_dialog.dart';

class TemplateEditPage extends StatefulWidget {
  final QuestionnaireTemplate? template;
  final VoidCallback? onSaved;

  const TemplateEditPage({
    super.key,
    this.template,
    this.onSaved,
  });

  @override
  State<TemplateEditPage> createState() => _TemplateEditPageState();
}

class _TemplateEditPageState extends State<TemplateEditPage> {
  final _formKey = GlobalKey<FormState>();
  final TemplateService _templateService = TemplateService();

  late String _name;
  late List<String> _standardFields;
  late List<CustomField> _customFields;
  bool _hasChanges = false;

  final List<String> _availableStandardFields = [
    'name',
    'age',
    'gender',
    'biography',
    'personality',
    'appearance',
    'abilities',
    'other',
    'image',
    'referenceImage',
    'additionalImages',
  ];

  @override
  void initState() {
    super.initState();
    _name = widget.template?.name ?? '';
    _standardFields = widget.template?.standardFields.toList() ?? [];
    _customFields = widget.template?.customFields.map((f) => f.copyWith()).toList() ?? [];
  }

  Future<bool> _hasUnsavedChanges() async {
    if (!_hasChanges) return false;

    final result = await UnsavedChangesDialog().show(context);
    if (result == null) return true;

    if (result == true) {
      await _saveTemplate();
    }
    return false;
  }

  Future<void> _saveTemplate() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final template = QuestionnaireTemplate(
        name: _name,
        standardFields: _standardFields,
        customFields: _customFields,
      );

      await _templateService.saveTemplate(template);
      setState(() => _hasChanges = false);
      if (widget.onSaved != null) widget.onSaved!();
      if (mounted) Navigator.pop(context);
    }
  }

  void _markAsChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final canPop = !await _hasUnsavedChanges();
        if (canPop && mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.template == null
                ? S.of(context).new_template
                : S.of(context).edit_template,
            style: textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.save, color: colorScheme.primary),
              onPressed: _saveTemplate,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            onChanged: _markAsChanged,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  label: S.of(context).template_name_label,
                  initialValue: _name,
                  isRequired: true,
                  onSaved: (value) => _name = value!,
                ),
                const SizedBox(height: 24),
                Text(
                  S.of(context).standard_fields,
                  style: textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableStandardFields.map((field) {
                    final isSelected = _standardFields.contains(field);
                    return FilterChip(
                      label: Text(
                        _getFieldDisplayName(field),
                        style: textTheme.labelLarge?.copyWith(
                          color: isSelected
                              ? colorScheme.onSecondaryContainer
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _standardFields.add(field);
                          } else {
                            _standardFields.remove(field);
                          }
                        });
                        _markAsChanged();
                      },
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      selectedColor: colorScheme.secondaryContainer,
                      shape: StadiumBorder(
                        side: BorderSide(
                          color: isSelected
                              ? colorScheme.secondaryContainer
                              : colorScheme.outline,
                        ),
                      ),
                      showCheckmark: false,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                CustomFieldsEditor(
                  initialFields: _customFields,
                  onFieldsChanged: (fields) {
                    _customFields = fields;
                    _markAsChanged();
                  },
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _saveTemplate,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    S.of(context).save_template,
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getFieldDisplayName(String field) {
    switch (field) {
      case 'name': return S.of(context).name;
      case 'age': return S.of(context).age;
      case 'gender': return S.of(context).gender;
      case 'biography': return S.of(context).biography;
      case 'personality': return S.of(context).personality;
      case 'appearance': return S.of(context).appearance;
      case 'abilities': return S.of(context).abilities;
      case 'other': return S.of(context).other;
      case 'image': return S.of(context).main_image;
      case 'referenceImage': return S.of(context).reference_image;
      case 'additionalImages': return S.of(context).additional_images;
      default: return field;
    }
  }
}