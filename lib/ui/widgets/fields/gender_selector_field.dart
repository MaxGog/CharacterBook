import 'package:flutter/material.dart';
import '../../../generated/l10n.dart';

class GenderSelectorField extends StatelessWidget {
  final String? initialValue;
  final ValueChanged<String?>? onChanged;
  final List<String> genders;
  final bool isRequired;

  const GenderSelectorField({
    super.key,
    this.initialValue,
    this.onChanged,
    this.genders = const ["male", "female", "another"],
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    final localizedGenders = genders.map((gender) {
      switch (gender) {
        case "male": return s.male;
        case "female": return s.female;
        case "another": return s.another;
        default: return gender;
      }
    }).toList();

    return DropdownButtonFormField<String>(
      value: initialValue,
      items: genders.asMap().entries.map((entry) {
        final index = entry.key;
        final gender = entry.value;
        return DropdownMenuItem(
          value: gender,
          child: Text(localizedGenders[index]),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: s.gender,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      style: Theme.of(context).textTheme.bodyLarge,
      validator: (value) => isRequired && (value == null || value.isEmpty)
          ? s.select_gender_error
          : null,
      onChanged: onChanged,
    );
  }
}