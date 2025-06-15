import 'package:flutter/material.dart';

class GenderSelectorField extends StatelessWidget {
  final String? initialValue;
  final ValueChanged<String?>? onChanged;
  final List<String> genders;
  final bool isRequired;

  const GenderSelectorField({
    super.key,
    this.initialValue,
    this.onChanged,
    this.genders = const ["Мужской", "Женский", "Другой"],
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: initialValue,
      items: genders.map((gender) => DropdownMenuItem(
        value: gender,
        child: Text(gender),
      )).toList(),
      decoration: InputDecoration(
        labelText: 'Пол',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      style: Theme.of(context).textTheme.bodyLarge,
      validator: (value) => isRequired && (value == null || value.isEmpty)
          ? 'Выберите пол'
          : null,
      onChanged: onChanged,
    );
  }
}