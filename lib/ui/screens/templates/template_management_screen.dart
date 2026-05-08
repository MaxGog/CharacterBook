import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/data/models/template_model.dart';
import 'package:characterbook/data/repositories/template_repository.dart';
import 'package:characterbook/ui/controllers/template_management_controller.dart';
import 'package:characterbook/ui/widgets/dialogs/error_dialog.dart';
import 'package:characterbook/ui/widgets/fields/custom_fields_editor.dart';
import 'package:characterbook/ui/widgets/fields/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TemplateManagementScreen extends StatefulWidget {
  final QuestionnaireTemplate? template;
  final VoidCallback? onSaved;

  const TemplateManagementScreen({super.key, this.template, this.onSaved});

  @override
  State<TemplateManagementScreen> createState() => _TemplateManagementScreenState();
}

class _TemplateManagementScreenState extends State<TemplateManagementScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  void _onTemplateSaveAttempt(TemplateManagementController controller) {
    if (!controller.isNameValid) {
      showErrorDialog(
        context: context,
        title: S.of(context).enter_title_template,
        message: S.of(context).save_error,
      );
      return;
    }
    _saveTemplate(controller)();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TemplateManagementController(
        repository: context.read<TemplateRepository>(),
        template: widget.template,
      ),
      child: Consumer<TemplateManagementController>(
        builder: (context, controller, child) {
          final s = S.of(context);
          final colorScheme = Theme.of(context).colorScheme;
          final textTheme = Theme.of(context).textTheme;

          return PopScope(
            canPop: false,
            onPopInvoked: (didPop) async {
              if (didPop) return;
              if (controller.hasUnsavedChanges) {
                final shouldPop = await _showUnsavedChangesDialog(context);
                if (shouldPop && mounted) Navigator.pop(context);
              } else {
                if (mounted) Navigator.pop(context);
              }
            },
            child: Scaffold(
              appBar: AppBar(
                title: Text(
                  widget.template == null ? s.new_template : s.edit_template,
                  style: textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                actions: [
                  if (controller.isSaving)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    )
                  else
                    IconButton(
                      icon: Icon(Icons.save, color: colorScheme.primary),
                      onPressed: () => _onTemplateSaveAttempt(controller),
                    ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        label: s.template_name_label,
                        initialValue: controller.name,
                        isRequired: true,
                        onSaved: (value) => controller.updateName(value ?? ''),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        s.standard_fields,
                        style: textTheme.titleLarge?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: TemplateManagementController.availableStandardFields
                            .map((field) {
                          final isSelected =
                              controller.standardFields.contains(field);
                          return FilterChip(
                            label: Text(
                              controller.getFieldDisplayName(field, context),
                              style: textTheme.labelLarge?.copyWith(
                                color: isSelected
                                    ? colorScheme.onSecondaryContainer
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (_) =>
                                controller.toggleStandardField(field),
                            backgroundColor:
                                colorScheme.surfaceContainerHighest,
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
                        initialFields: controller.customFields,
                        onFieldsChanged: controller.setCustomFields,
                      ),
                      const SizedBox(height: 24),
                      if (controller.error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            controller.error!,
                            style: TextStyle(color: colorScheme.error),
                          ),
                        ),
                      FilledButton(
                        onPressed: _saveTemplate(controller),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          s.save_template,
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
        },
      ),
    );
  }

  VoidCallback _saveTemplate(TemplateManagementController controller) {
    return () async {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        final success = await controller.save();
        if (success && mounted) {
          if (widget.onSaved != null) widget.onSaved!();
          Navigator.pop(context);
        }
      }
    };
  }

  Future<bool> _showUnsavedChangesDialog(BuildContext context) async {
    final s = S.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.unsaved_changes_title),
        content: Text(s.unsaved_changes_content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.close),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
