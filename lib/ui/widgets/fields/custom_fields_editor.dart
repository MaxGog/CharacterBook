import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../../models/custom_field_model.dart';
import 'custom_text_field.dart';

class CustomFieldsEditor extends StatefulWidget {
  final List<CustomField> initialFields;
  final ValueChanged<List<CustomField>> onFieldsChanged;

  const CustomFieldsEditor({
    super.key,
    required this.initialFields,
    required this.onFieldsChanged,
  });

  @override
  State<CustomFieldsEditor> createState() => _CustomFieldsEditorState();
}

class _CustomFieldsEditorState extends State<CustomFieldsEditor> {
  late List<CustomField> _fields;

  @override
  void initState() {
    super.initState();
    _fields = widget.initialFields.map((f) => f.copyWith()).toList();
  }

  void _addField() {
    setState(() {
      final hasEmpty = _fields.any((f) => f.key.isEmpty && f.value.isEmpty);
      if (!hasEmpty) {
        _fields.add(CustomField('', ''));
        _notifyParent();
      }
    });
  }

  void _updateField(int index, String key, String value) {
    setState(() {
      if (key.trim().isEmpty && value.trim().isEmpty) {
        _fields.removeAt(index);
      } else {
        _fields[index] = CustomField(key.trim(), value.trim());
      }
      _notifyParent();
    });
  }

  void _removeField(int index) {
    setState(() {
      _fields.removeAt(index);
      _notifyParent();
    });
  }

  void _notifyParent() {
    widget.onFieldsChanged(_fields.where((f) => f.key.isNotEmpty).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(S.of(context).custom_fields, style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addField,
              tooltip: S.of(context).create,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._fields.asMap().entries.map((entry) {
          final index = entry.key;
          final field = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: CustomTextField(
                    initialValue: field.key,
                    label: S.of(context).template_name_label,
                    onChanged: (value) => _updateField(index, value, field.value),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: CustomTextField(
                    initialValue: field.value,
                    label: S.of(context).description,
                    onChanged: (value) => _updateField(index, field.key, value),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _removeField(index),
                  tooltip: S.of(context).delete,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}