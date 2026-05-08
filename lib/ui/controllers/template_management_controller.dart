import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/data/models/custom_field_model.dart';
import 'package:characterbook/data/models/template_model.dart';
import 'package:characterbook/data/repositories/template_repository.dart';
import 'package:flutter/material.dart';

class TemplateManagementController extends ChangeNotifier {
  final TemplateRepository _repository;
  final QuestionnaireTemplate? _originalTemplate;

  late String _name;
  late List<String> _standardFields;
  late List<CustomField> _customFields;
  bool _hasUnsavedChanges = false;
  String? _error;
  bool _isSaving = false;

  static const List<String> availableStandardFields = [
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

  String get name => _name;
  List<String> get standardFields => List.unmodifiable(_standardFields);
  List<CustomField> get customFields => List.unmodifiable(_customFields);
  bool get hasUnsavedChanges => _hasUnsavedChanges;
  bool get isSaving => _isSaving;
  String? get error => _error;
  bool get isNameValid => _name.trim().isNotEmpty;

  TemplateManagementController({
    required TemplateRepository repository,
    QuestionnaireTemplate? template,
  })  : _repository = repository,
        _originalTemplate = template {
    _name = template?.name ?? '';
    _standardFields = template?.standardFields.toList() ?? [];
    _customFields =
        template?.customFields.map((f) => f.copyWith()).toList() ?? [];
  }

  void updateName(String name) {
    if (_name == name) return;
    _name = name;
    _markUnsaved();
  }

  void toggleStandardField(String field) {
    if (_standardFields.contains(field)) {
      _standardFields.remove(field);
    } else {
      _standardFields.add(field);
    }
    _markUnsaved();
  }

  void setCustomFields(List<CustomField> fields) {
    _customFields = fields;
    _markUnsaved();
  }

  void _markUnsaved() {
    if (!_hasUnsavedChanges) {
      _hasUnsavedChanges = true;
      notifyListeners();
    } else {
      notifyListeners();
    }
  }

  Future<bool> save() async {
    if (_name.trim().isEmpty) return false;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final template = QuestionnaireTemplate(
        name: _name.trim(),
        standardFields: _standardFields,
        customFields: _customFields,
      );
      await _repository.save(template, name: _originalTemplate?.name);
      _hasUnsavedChanges = false;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  String getFieldDisplayName(String field, BuildContext context) {
    final s = S.of(context);
    switch (field) {
      case 'name':
        return s.name;
      case 'age':
        return s.age;
      case 'gender':
        return s.gender;
      case 'biography':
        return s.biography;
      case 'personality':
        return s.personality;
      case 'appearance':
        return s.appearance;
      case 'abilities':
        return s.abilities;
      case 'other':
        return s.other;
      case 'image':
        return s.main_image;
      case 'referenceImage':
        return s.reference_image;
      case 'additionalImages':
        return s.additional_images;
      default:
        return field;
    }
  }
}
