import 'dart:typed_data';
import 'package:characterbook/data/models/race_model.dart';
import 'package:characterbook/data/repositories/race_repository.dart';
import 'package:flutter/material.dart';

class RaceManagementController extends ChangeNotifier {
  final RaceRepository _raceRepo;

  final Race? _originalRace;

  late Race _editable;
  List<String> _tags = [];

  bool _isLoading = false;
  String? _error;
  bool _hasUnsavedChanges = false;

  RaceManagementController({
    required RaceRepository raceRepo,
    Race? race,
  })  : _raceRepo = raceRepo,
        _originalRace = race {
    _initialize();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  Race get race => _editable;
  List<String> get tags => _tags;
  bool get hasUnsavedChanges => _hasUnsavedChanges;

  void _initialize() {
    if (_originalRace != null) {
      _editable = _originalRace!.copyWith();
      _tags = List.from(_editable.tags);
      _hasUnsavedChanges = false;
    } else {
      _editable = Race(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: '',
      );
      _tags = [];
      _hasUnsavedChanges = true;
    }
  }
  void updateName(String name) {
    _editable.name = name;
    _markUnsaved(notify: false);
  }

  void updateDescription(String description) {
    _editable.description = description;
    _markUnsaved();
  }

  void updateBiology(String biology) {
    _editable.biology = biology;
    _markUnsaved();
  }

  void updateBackstory(String backstory) {
    _editable.backstory = backstory;
    _markUnsaved();
  }

  void updateLogo(Uint8List? bytes) {
    _editable.logo = bytes;
    _markUnsaved();
  }

  void setTags(List<String> tags) {
    _tags = tags;
    _editable.tags = tags;
    _markUnsaved();
  }

  void _markUnsaved({bool notify = true}) {
    if (!_hasUnsavedChanges) {
      _hasUnsavedChanges = true;
    }
    if (notify) {
      notifyListeners();
    }
  }

  Future<bool> save() async {
    if (_editable.name.isEmpty) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final key = _originalRace?.key;
      await _raceRepo.save(_editable, key: key);

      _hasUnsavedChanges = false;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
