import 'dart:typed_data';
import 'package:characterbook/data/models/folder_model.dart';
import 'package:characterbook/data/models/race_model.dart';
import 'package:characterbook/data/repositories/folder_repository.dart';
import 'package:characterbook/data/repositories/race_repository.dart';
import 'package:flutter/material.dart';

class RaceManagementController extends ChangeNotifier {
  final RaceRepository _raceRepo;
  final FolderRepository _folderRepo;

  final Race? _originalRace;

  late Race _editable;
  List<Folder> _availableFolders = [];
  Folder? _selectedFolder;
  List<String> _tags = [];

  bool _isLoading = false;
  String? _error;
  bool _hasUnsavedChanges = false;

  RaceManagementController({
    required RaceRepository raceRepo,
    required FolderRepository folderRepo,
    Race? race,
  })  : _raceRepo = raceRepo,
        _folderRepo = folderRepo,
        _originalRace = race {
    _initialize();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  Race get race => _editable;
  List<Folder> get availableFolders => _availableFolders;
  Folder? get selectedFolder => _selectedFolder;
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
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    _isLoading = true;
    notifyListeners();
    try {
      _availableFolders = await _folderRepo.getByType(FolderType.race);
      if (_editable.folderId != null) {
        try {
          _selectedFolder = _availableFolders.firstWhere(
            (f) => f.id == _editable.folderId,
          );
        } catch (_) {}
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _autoSave() {
    save();
  }

  void updateName(String name) {
    if (name.trim().isEmpty) return;
    _editable.name = name;
    _autoSave();
    _markUnsaved();
  }

  void updateDescription(String description) {
    _editable.description = description;
    _autoSave();
    _markUnsaved();
  }

  void updateBiology(String biology) {
    _editable.biology = biology;
    _autoSave();
    _markUnsaved();
  }

  void updateBackstory(String backstory) {
    _editable.backstory = backstory;
    _autoSave();
    _markUnsaved();
  }

  void updateLogo(Uint8List? bytes) {
    _editable.logo = bytes;
    _autoSave();
    _markUnsaved();
  }

  void setTags(List<String> tags) {
    _tags = tags;
    _editable.tags = tags;
    _autoSave();
    _markUnsaved();
  }

  void setSelectedFolder(Folder? folder) {
    _selectedFolder = folder;
    _editable.folderId = folder?.id;
    _autoSave();
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
    if (_editable.name.isEmpty) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final key = _originalRace?.key;
      await _raceRepo.save(_editable, key: key);

      if (_selectedFolder != null && key != null) {
        await _folderRepo.addToFolder(_selectedFolder!.id, key.toString());
      }

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
