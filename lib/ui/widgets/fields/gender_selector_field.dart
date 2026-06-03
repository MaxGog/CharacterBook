import 'package:characterbook/generated/l10n.dart';
import 'package:flutter/material.dart';

class GenderSelectorField extends StatefulWidget {
  final String? initialValue;
  final ValueChanged<String?>? onChanged;
  final List<String> genders;
  final bool isRequired;

  const GenderSelectorField({
    super.key,
    this.initialValue,
    this.onChanged,
    this.genders = const ['male', 'female', 'another'],
    this.isRequired = false,
  });

  @override
  State<GenderSelectorField> createState() => _GenderSelectorFieldState();
}

class _GenderSelectorFieldState extends State<GenderSelectorField> {
  late final TextEditingController _controller;

  Map<String, String> _localizedGenders(S s) => {
        'male': s.male,
        'female': s.female,
        'another': s.another,
      };

  Map<String, IconData> get _genderIcons => {
        'male': Icons.male_rounded,
        'female': Icons.female_rounded,
        'another': Icons.transgender_rounded,
      };

  String _displayValue(S s, String? value) {
    if (value == null || value.isEmpty) return '';
    final localized = _localizedGenders(s);
    if (widget.genders.contains(value)) {
      return localized[value] ?? value;
    }

    final match = localized.entries.firstWhere(
      (entry) => entry.value.toLowerCase() == value.toLowerCase(),
      orElse: () => const MapEntry('', ''),
    );
    return match.key.isNotEmpty ? match.value : value;
  }

  String _valueFromText(S s, String text) {
    final localized = _localizedGenders(s);
    final match = localized.entries.firstWhere(
      (entry) => entry.value.toLowerCase() == text.toLowerCase(),
      orElse: () => const MapEntry('', ''),
    );
    return match.key.isNotEmpty ? match.key : text.trim();
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.text = _displayValue(S.of(context), widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant GenderSelectorField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _controller.text = _displayValue(S.of(context), widget.initialValue);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openGenderDialog(BuildContext context) async {
    final s = S.of(context);
    final initialValue = _controller.text;

    final selectedGender = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return _GenderSelectionDialog(
          initialValue: initialValue,
          genders: widget.genders,
          genderIcons: _genderIcons,
          localizedGenders: _localizedGenders(s),
          title: s.gender,
          customLabel: s.custom,
          hintText: s.enterName,
          cancelLabel: s.cancel,
          doneLabel: s.done,
        );
      },
    );

    if (!mounted || selectedGender == null) return;

    final value = _valueFromText(s, selectedGender);
    _controller.text = _displayValue(s, value);
    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return TextFormField(
      controller: _controller,
      readOnly: true,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.transgender_rounded),
        labelText: s.gender,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(102),
        suffixIcon: IconButton(
          icon: Icon(
            Icons.arrow_drop_down_rounded,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          tooltip: s.select,
          onPressed: () => _openGenderDialog(context),
        ),
      ),
      style: Theme.of(context).textTheme.bodyLarge,
      validator: (value) => widget.isRequired && (value == null || value.trim().isEmpty)
          ? s.select_gender_error
          : null,
      onTap: () => _openGenderDialog(context),
    );
  }
}

class _GenderSelectionDialog extends StatefulWidget {
  final String initialValue;
  final List<String> genders;
  final Map<String, IconData> genderIcons;
  final Map<String, String> localizedGenders;
  final String title;
  final String customLabel;
  final String hintText;
  final String cancelLabel;
  final String doneLabel;

  const _GenderSelectionDialog({
    required this.initialValue,
    required this.genders,
    required this.genderIcons,
    required this.localizedGenders,
    required this.title,
    required this.customLabel,
    required this.hintText,
    required this.cancelLabel,
    required this.doneLabel,
  });

  @override
  State<_GenderSelectionDialog> createState() => _GenderSelectionDialogState();
}

class _GenderSelectionDialogState extends State<_GenderSelectionDialog> {
  late final TextEditingController _popupController;

  @override
  void initState() {
    super.initState();
    _popupController = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _popupController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _popupController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: widget.customLabel,
              hintText: widget.hintText,
              prefixIcon: const Icon(Icons.edit_rounded),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              Navigator.of(context).pop(_popupController.text.trim());
            },
            autofocus: true,
          ),
          const SizedBox(height: 16),
          ...widget.genders.map((gender) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(widget.genderIcons[gender] ?? Icons.person_outline),
              title: Text(widget.localizedGenders[gender] ?? gender),
              onTap: () => Navigator.of(context).pop(gender),
            );
          }),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text(widget.cancelLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_popupController.text.trim()),
          child: Text(widget.doneLabel),
        ),
      ],
    );
  }
}
