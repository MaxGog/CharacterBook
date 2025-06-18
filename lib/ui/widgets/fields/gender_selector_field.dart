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

    final genderLocalizations = {
      "male": s.male,
      "female": s.female,
      "another": s.another,
    };

    return DropdownButtonFormField<String>(
      value: genders.contains(initialValue) ? initialValue : null,
      items: genders.map((gender) {
        return DropdownMenuItem(
          value: gender,
          child: Text(genderLocalizations[gender] ?? gender),
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