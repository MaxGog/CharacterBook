import 'dart:async';
import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/data/models/note_model.dart';
import 'package:characterbook/data/repositories/note_repository.dart';
import 'package:characterbook/services/clipboard_service.dart';
import 'package:characterbook/data/services/note_service.dart';
import 'package:flutter/material.dart';

class NoteManagementController extends ChangeNotifier {
  final NoteRepository _noteRepo;
  final NoteService? _noteService;

  final Note? _originalNote;
  final bool isCopyMode;

  late Note _editable;
  bool autoGenerateTitle = true;
  List<String> _tags = [];
  List<String> _selectedCharacterIds = [];

  dynamic _currentKey;

  bool _isLoading = false;
  String? _error;
  bool _hasUnsavedChanges = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get title => _editable.title;
  String get content => _editable.content;
  List<String> get selectedCharacterIds =>
      List.unmodifiable(_selectedCharacterIds);
  List<String> get tags => List.unmodifiable(_tags);
  bool get hasUnsavedChanges => _hasUnsavedChanges;

  NoteManagementController({
    required NoteRepository noteRepo,
    NoteService? noteService,
    Note? note,
    this.isCopyMode = false,
  })  : _noteRepo = noteRepo,
        _noteService = noteService,
        _originalNote = note {
    _initialize();
  }

  void _initialize() {
    if (_originalNote != null) {
      _currentKey = _originalNote!.key;

      final String idStr = _originalNote!.id.toString();

      if (isCopyMode) {
        _editable = _originalNote!.copyWith(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: '${S.current.copy}: ${_originalNote!.title}',
        );
        _currentKey = null;
      } else {
        _editable = _originalNote!.copyWith(
          id: idStr,
        );
      }
      _hasUnsavedChanges = false;
    } else {
      _editable = Note(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: '',
        content: '',
        folderId: '',
      );
      _currentKey = null;
      _hasUnsavedChanges = true;
    }
    _tags = List.from(_editable.tags);
    _selectedCharacterIds = List.from(_editable.characterIds);
  }

  void _autoSave() {
    save();
  }

  void updateTitle(String title) {
    if (_editable.title == title) return;
    _editable.title = title;
    _markUnsaved();
    _autoSave();
  }

  void updateContent(String content) {
    if (_editable.content == content) return;
    _editable.content = content;
    _markUnsaved();
    _autoSave();
  }

  void addCharacterId(String id) {
    if (!_selectedCharacterIds.contains(id)) {
      _selectedCharacterIds.add(id);
      _editable.characterIds = _selectedCharacterIds;
      _markUnsaved();
      _autoSave();
    }
  }

  void removeCharacterId(String id) {
    if (_selectedCharacterIds.contains(id)) {
      _selectedCharacterIds.remove(id);
      _editable.characterIds = _selectedCharacterIds;
      _markUnsaved();
      _autoSave();
    }
  }

  void setTags(List<String> tags) {
    _tags = tags;
    _editable.tags = tags;
    _markUnsaved();
    _autoSave();
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
    if (_editable.title.trim().isEmpty) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final key = await _noteRepo.save(_editable, key: _currentKey);
      _currentKey ??= key;
      _hasUnsavedChanges = false;
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> copyToClipboard(BuildContext context) async {
    await ClipboardService.copyNoteToClipboard(
      context: context,
      content: _editable.content,
    );
  }

  Future<void> share(BuildContext context) async {
    if (_noteService != null) {
      await _noteService!.shareNote(context, _editable);
    } else {
      throw Exception('NoteService not provided');
    }
  }
}
