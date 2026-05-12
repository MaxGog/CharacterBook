import 'package:characterbook/ui/screens/field_editor_screen.dart';
import 'package:flutter/material.dart';
import 'package:characterbook/data/models/custom_field_model.dart';
import 'package:characterbook/generated/l10n.dart';

class CustomFieldsEditor extends StatefulWidget {
  final List<CustomField> initialFields;
  final ValueChanged<List<CustomField>> onFieldsChanged;
  final bool verticalLayout;
  final bool useFullscreenEditor;

  const CustomFieldsEditor({
    super.key,
    required this.initialFields,
    required this.onFieldsChanged,
    this.verticalLayout = false,
    this.useFullscreenEditor = false,
  });

  @override
  State<CustomFieldsEditor> createState() => _CustomFieldsEditorState();
}

class _CustomFieldsEditorState extends State<CustomFieldsEditor> {
  late List<CustomField> _fields;
  late List<TextEditingController> _keyControllers;
  late List<TextEditingController> _valueControllers;
  late bool _isFullscreenMode;

  @override
  void initState() {
    super.initState();
    _fields = widget.initialFields.map((f) => f.copyWith()).toList();
    _isFullscreenMode = widget.useFullscreenEditor;
    if (!_isFullscreenMode) {
      _initializeControllers();
    } else {
      _keyControllers = [];
      _valueControllers = [];
    }
  }

  void _initializeControllers() {
    _keyControllers = _fields.map((field) {
      final controller = TextEditingController(text: field.key);
      controller.addListener(() {
        final index = _keyControllers.indexOf(controller);
        if (index != -1) {
          _updateField(index, controller.text, _valueControllers[index].text);
        }
      });
      return controller;
    }).toList();

    _valueControllers = _fields.map((field) {
      final controller = TextEditingController(text: field.value);
      controller.addListener(() {
        final index = _valueControllers.indexOf(controller);
        if (index != -1) {
          _updateField(index, _keyControllers[index].text, controller.text);
        }
      });
      return controller;
    }).toList();
  }

  void _addField() {
    setState(() {
      final newField = CustomField('', '');
      _fields.add(newField);

      if (!_isFullscreenMode) {
        final keyController = TextEditingController();
        keyController.addListener(() {
          final index = _keyControllers.indexOf(keyController);
          if (index != -1) {
            _updateField(
                index, keyController.text, _valueControllers[index].text);
          }
        });
        _keyControllers.add(keyController);

        final valueController = TextEditingController();
        valueController.addListener(() {
          final index = _valueControllers.indexOf(valueController);
          if (index != -1) {
            _updateField(
                index, _keyControllers[index].text, valueController.text);
          }
        });
        _valueControllers.add(valueController);
      }
    });
    widget.onFieldsChanged(_fields);
  }

  void _removeField(int index) {
    final removedField = _fields[index];
    final removedKeyController =
        _isFullscreenMode ? null : _keyControllers[index];
    final removedValueController =
        _isFullscreenMode ? null : _valueControllers[index];

    setState(() {
      _fields.removeAt(index);
      if (!_isFullscreenMode) {
        _keyControllers.removeAt(index);
        _valueControllers.removeAt(index);
      }
    });
    widget.onFieldsChanged(_fields);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(S.of(context).field_removed),
        action: SnackBarAction(
          label: S.of(context).undo,
          onPressed: () {
            setState(() {
              _fields.insert(index, removedField);
              if (!_isFullscreenMode) {
                _keyControllers.insert(index, removedKeyController!);
                _valueControllers.insert(index, removedValueController!);
              }
            });
            widget.onFieldsChanged(_fields);
          },
        ),
      ),
    );
  }

  void _updateField(int index, String key, String value) {
    setState(() {
      _fields[index] = CustomField(key, value);
    });
    widget.onFieldsChanged(_fields);
  }

  @override
  void dispose() {
    if (!_isFullscreenMode) {
      for (final controller in _keyControllers) {
        controller.dispose();
      }
      for (final controller in _valueControllers) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  Future<void> _editFieldFullscreen(int index) async {
    final field = _fields[index];
    final s = S.of(context);
    final result = await Navigator.push<FieldEditorResult>(
      context,
      MaterialPageRoute(
        builder: (_) => FieldEditorScreen(
          initialKey: field.key,
          initialValue: field.value,
          title: field.key.isNotEmpty ? field.key : s.field_name,
          isTitleEditable: true,
        ),
      ),
    );
    if (result != null) {
      setState(() {
        _fields[index] = CustomField(result.key, result.value);
      });
      widget.onFieldsChanged(_fields);
    }
  }

  void _addAndEditField() async {
    setState(() {
      _fields.add(CustomField('', ''));
    });
    widget.onFieldsChanged(_fields);
    await _editFieldFullscreen(_fields.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

    if (_isFullscreenMode) {
      return _buildFullscreenLayout(s, theme);
    }

    if (widget.verticalLayout) {
      return _buildVerticalLayout(s, theme);
    } else {
      return _buildHorizontalLayout(s, theme);
    }
  }

  Widget _buildFullscreenFieldItem(
      int index, CustomField field, S s, ThemeData theme) {
    final title = field.key.isEmpty ? s.field_name : field.key;
    return Card.outlined(
      key: ValueKey('${field.key}_${field.value}_$index'),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: ReorderableDragStartListener(
        index: index,
        key: ValueKey('${field.key}_${field.value}_$index'),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          leading: Icon(Icons.drag_handle,
              color: theme.colorScheme.onSurfaceVariant),
          title: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: field.key.isEmpty
                  ? theme.colorScheme.onSurfaceVariant
                  : theme.colorScheme.onSurface,
            ),
          ),
          subtitle: field.value.isNotEmpty
              ? Text(
                  field.value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                )
              : const SizedBox.shrink(),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.edit_outlined,
                  size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: theme.colorScheme.error,
                tooltip: s.delete,
                onPressed: () => _removeField(index),
              ),
            ],
          ),
          onTap: () => _editFieldFullscreen(index),
        ),
      ),
    );
  }

  Widget _buildFullscreenLayout(S s, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.custom_fields_editor_title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.custom_fields_editor_subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.tonalIcon(
              onPressed: _addAndEditField,
              icon: const Icon(Icons.add_rounded),
              label: Text(s.add_field),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (_fields.isNotEmpty)
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _fields.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex--;
                final field = _fields.removeAt(oldIndex);
                _fields.insert(newIndex, field);
              });
              widget.onFieldsChanged(_fields);
            },
            itemBuilder: (context, index) {
              return _buildFullscreenFieldItem(index, _fields[index], s, theme);
            },
          ),
        if (_fields.isEmpty)
          _buildEmptyCallToAction(s, theme,
              onTap: _addAndEditField, isFullscreen: true),
      ],
    );
  }

  Widget _buildVerticalLayout(S s, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.custom_fields_editor_title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.custom_fields_editor_subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.tonalIcon(
              onPressed: _addField,
              icon: const Icon(Icons.add_rounded),
              label: Text(s.add_field),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (_fields.isNotEmpty)
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _fields.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex--;
                final field = _fields.removeAt(oldIndex);
                _fields.insert(newIndex, field);
                final keyCtrl = _keyControllers.removeAt(oldIndex);
                _keyControllers.insert(newIndex, keyCtrl);
                final valCtrl = _valueControllers.removeAt(oldIndex);
                _valueControllers.insert(newIndex, valCtrl);
              });
              widget.onFieldsChanged(_fields);
            },
            itemBuilder: (context, index) {
              return _buildVerticalFieldItem(index, s, theme);
            },
          ),
        if (_fields.isEmpty)
          _buildEmptyCallToAction(s, theme, onTap: _addField),
      ],
    );
  }

  Widget _buildVerticalFieldItem(int index, S s, ThemeData theme) {
    return Card.filled(
      key: ValueKey(
          'v_${_keyControllers[index].text}_${_valueControllers[index].text}_$index'),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReorderableDragStartListener(
              index: index,
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Icon(
                  Icons.drag_handle,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                children: [
                  TextField(
                    controller: _keyControllers[index],
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      labelText: s.field_name,
                      hintText: s.field_name_hint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _valueControllers[index],
                    style: theme.textTheme.bodyLarge,
                    maxLines: null,
                    minLines: 2,
                    decoration: InputDecoration(
                      labelText: s.field_value,
                      hintText: s.field_value_hint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      alignLabelWithHint: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: theme.colorScheme.error,
              tooltip: s.delete,
              onPressed: () => _removeField(index),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalLayout(S s, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.custom_fields,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.custom_fields_editor_subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.tonalIcon(
              onPressed: _addField,
              icon: const Icon(Icons.add_rounded),
              label: Text(s.add_field),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: _fields.asMap().entries.map((entry) {
              final index = entry.key;
              return _buildHorizontalFieldItem(index, s, theme);
            }).toList(),
          ),
        ),
        if (_fields.isEmpty)
          _buildEmptyCallToAction(s, theme, onTap: _addField),
      ],
    );
  }

  Widget _buildHorizontalFieldItem(int index, S s, ThemeData theme) {
    return SizedBox(
      width: 320,
      child: Card.filled(
        key: ValueKey(
            'v_${_keyControllers[index].text}_${_valueControllers[index].text}_$index'),
        margin: const EdgeInsets.only(right: 16, bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  ReorderableDragStartListener(
                    index: index,
                    child: Icon(
                      Icons.drag_handle,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: theme.colorScheme.error,
                    tooltip: s.delete,
                    onPressed: () => _removeField(index),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _keyControllers[index],
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  labelText: s.field_name,
                  hintText: s.field_name_hint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _valueControllers[index],
                style: theme.textTheme.bodyLarge,
                maxLines: null,
                minLines: 3,
                decoration: InputDecoration(
                  labelText: s.field_value,
                  hintText: s.field_value_hint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCallToAction(S s, ThemeData theme,
      {required VoidCallback onTap, bool isFullscreen = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isFullscreen ? Icons.edit_note_rounded : Icons.notes_rounded,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            s.no_custom_fields,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            s.custom_fields_editor_subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.tonalIcon(
            onPressed: onTap,
            icon: const Icon(Icons.add_rounded),
            label: Text(s.add_field),
          ),
        ],
      ),
    );
  }
}
