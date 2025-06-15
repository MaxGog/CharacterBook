import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? initialValue;
  final int? maxLines;
  final bool isRequired;
  final bool alignLabel;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final EditableTextContextMenuBuilder? contextMenuBuilder;

  const CustomTextField({
    super.key,
    required this.label,
    this.initialValue,
    this.maxLines = 1,
    this.isRequired = false,
    this.alignLabel = false,
    this.onSaved,
    this.validator,
    this.onChanged,
    this.controller,
    this.keyboardType,
    this.contextMenuBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        alignLabelWithHint: alignLabel,
      ),
      style: theme.textTheme.bodyLarge,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator ?? (isRequired ? _defaultValidator : null),
      onSaved: onSaved,
      onChanged: onChanged,
      contextMenuBuilder: contextMenuBuilder,
    );
  }

  String? _defaultValidator(String? value) {
    if (value?.isEmpty ?? true) return 'Обязательное поле';
    return null;
  }
}