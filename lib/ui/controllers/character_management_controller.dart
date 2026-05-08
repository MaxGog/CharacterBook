import 'dart:async';
import 'dart:typed_data';

import 'package:characterbook/data/models/character_model.dart';
import 'package:characterbook/data/models/custom_field_model.dart';
import 'package:characterbook/data/models/race_model.dart';
import 'package:characterbook/data/models/template_model.dart';
import 'package:characterbook/data/repositories/character_repository.dart';
import 'package:characterbook/data/repositories/race_repository.dart';
import 'package:flutter/material.dart';

class CharacterManagementController extends ChangeNotifier {
  final CharacterRepository _characterRepo;
  final RaceRepository _raceRepo;

  Character? _originalCharacter;
  final QuestionnaireTemplate? _template;

  late Character _editable;
  List<Race> _availableRaces = [];
  List<CustomField> _customFields = [];
  List<String> _tags = [];
  List<Uint8List> _additionalImages = [];

  bool _isLoading = false;
  String? _error;
  bool _hasUnsavedChanges = false;
  bool _isSaving = false;
  Timer? _autoSaveTimer;
  
  dynamic _currentKey;

  CharacterManagementController({
    required CharacterRepository characterRepo,
    required RaceRepository raceRepo,
    Character? character,
    QuestionnaireTemplate? template,
  })  : _characterRepo = characterRepo,
        _raceRepo = raceRepo,
        _originalCharacter = character,
        _template = template {
    _initialize();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  Character get character => _editable;
  List<Race> get availableRaces => _availableRaces;
  List<CustomField> get customFields => _customFields;
  List<String> get tags => _tags;
  List<Uint8List> get additionalImages => _additionalImages;
  bool get hasUnsavedChanges => _hasUnsavedChanges;

  void _initialize() {
    if (_originalCharacter != null) {
      _currentKey = _originalCharacter!.key;
      _editable = _originalCharacter!.copyWith();
      _customFields = _editable.customFields.map((f) => f.copyWith()).toList();
      _tags = List.from(_editable.tags);
      _additionalImages = List.from(_editable.additionalImages);
      _hasUnsavedChanges = false;
    } else if (_template != null) {
      _editable = _template!.applyToCharacter(Character.empty());
      _customFields = _editable.customFields.map((f) => f.copyWith()).toList();
      _tags = List.from(_editable.tags);
      _additionalImages = List.from(_editable.additionalImages);
      _hasUnsavedChanges = true;
    } else {
      _currentKey = null;
      _editable = Character.empty();
      _customFields = [];
      _tags = [];
      _additionalImages = [];
      _hasUnsavedChanges = true;
    }
    _loadRacesAndFolders();
  }

  Future<void> _loadRacesAndFolders() async {
    _isLoading = true;
    notifyListeners();
    try {
      _availableRaces = await _raceRepo.getAll();

      if (_editable.race != null &&
          !_availableRaces.any((r) => r.id == _editable.race!.id)) {
        _availableRaces.add(_editable.race!);
      }

    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _autoSave() {
    if (_originalCharacter == null) return;
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(milliseconds: 500), () {
      save();
    });
  }

  void updateName(String name) {
    if (name.trim().isEmpty) return;
    _editable = _editable.copyWith(name: name);
    _autoSave();
    _markUnsaved();
  }

  void updateAge(int age) {
    _editable = _editable.copyWith(age: age);
    _autoSave();
    _markUnsaved();
  }

  void updateGender(String gender) {
    _editable = _editable.copyWith(gender: gender);
    _autoSave();
    _markUnsaved();
  }

  void updateRace(Race? race) {
    _editable = _editable.copyWith(
      race: race != null ? Race(id: race.id, name: race.name) : null,
    );
    _autoSave();
    _markUnsaved();
  }

  void updateMainImage(Uint8List? bytes) {
    _editable = _editable.copyWith(imageBytes: bytes);
    _autoSave();
    _markUnsaved();
  }

  void updateReferenceImage(Uint8List? bytes) {
    _editable = _editable.copyWith(referenceImageBytes: bytes);
    _autoSave();
    _markUnsaved();
  }

  void addAdditionalImage(Uint8List bytes) {
    _additionalImages.add(bytes);
    _autoSave();
    _updateAdditionalImages();
  }

  void removeAdditionalImage(int index) {
    _additionalImages.removeAt(index);
    _autoSave();
    _updateAdditionalImages();
  }

  void insertAdditionalImage(int index, Uint8List bytes) {
    _additionalImages.insert(index, bytes);
    _autoSave();
    _updateAdditionalImages();
  }

  void _updateAdditionalImages() {
    _editable = _editable.copyWith(additionalImages: _additionalImages);
    _autoSave();
    _markUnsaved();
  }

  void setTags(List<String> tags) {
    _tags = tags;
    _editable = _editable.copyWith(tags: tags);
    _autoSave();
    _markUnsaved();
  }

  void setCustomFields(List<CustomField> fields) {
    _customFields = fields.map((f) => f.copyWith()).toList();
    _editable = _editable.copyWith(customFields: _customFields);
    _markUnsaved();
  }

  void updateTextField(String field, String value) {
    switch (field) {
      case 'appearance':
        _editable = _editable.copyWith(appearance: value);
        break;
      case 'personality':
        _editable = _editable.copyWith(personality: value);
        break;
      case 'biography':
        _editable = _editable.copyWith(biography: value);
        break;
      case 'abilities':
        _editable = _editable.copyWith(abilities: value);
        break;
      case 'other':
        _editable = _editable.copyWith(other: value);
        break;
    }
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

  Future<bool> save({bool closeAfterSave = false}) async {
    _autoSaveTimer?.cancel();
    if (_isSaving) return false;
    if (_editable.name.trim().isEmpty) {
      _error = 'Имя не может быть пустым';
      notifyListeners();
      return false;
    }
    if (_editable.race == null) {
      _error = 'Необходимо выбрать расу';
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final key = _currentKey;
      final savedKey = await _characterRepo.save(_editable, key: key);
      _currentKey ??= savedKey;
      _originalCharacter ??= _editable;
      _hasUnsavedChanges = false;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      _isSaving = false;
      notifyListeners();
    }
  }
}
