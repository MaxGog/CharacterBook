import 'dart:async';

import 'package:characterbook/data/models/character_model.dart';
import 'package:characterbook/data/models/note_model.dart';
import 'package:characterbook/data/models/relationship_model.dart';
import 'package:characterbook/data/repositories/character_repository.dart';
import 'package:characterbook/data/repositories/note_repository.dart';
import 'package:characterbook/data/services/character_service.dart';
import 'package:characterbook/data/services/relationship_service.dart';
import 'package:characterbook/services/clipboard_service.dart';
import 'package:characterbook/data/services/note_service.dart';
import 'package:flutter/material.dart';

class CharacterModalController extends ChangeNotifier {
  final Character character;
  final CharacterRepository _characterRepo;
  final NoteRepository _noteRepo;
  final CharacterService _characterService;
  final RelationshipService _relationshipService;

  List<Note> _relatedNotes = [];
  bool _isLoading = false;
  String? _error;
  final Map<String, bool> _expandedSections = {
    'gallery': true,
    'appearance': true,
    'personality': true,
    'biography': true,
    'abilities': true,
    'other': true,
    'customFields': true,
    'notes': true,
    'relationships': true,
  };

  Map<String, Character> _characterMap = {};
  List<Relationship> _relationships = [];
  StreamSubscription<List<Relationship>>? _relSub;

  CharacterModalController({
    required this.character,
    required CharacterRepository characterRepo,
    required NoteRepository noteRepo,
    required CharacterService characterService,
    required NoteService noteService,
    required ClipboardService clipboardService,
    required RelationshipService relationshipService,
  })  : _characterRepo = characterRepo,
        _noteRepo = noteRepo,
        _characterService = characterService, 
        _relationshipService = relationshipService {
    _loadData();
  }

  List<Note> get relatedNotes => _relatedNotes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, bool> get expandedSections => _expandedSections;
  List<Relationship> get relationships => _relationships;

  Character? getCharacter(String id) => _characterMap[id];

  void toggleSection(String key) {
    _expandedSections[key] = !(_expandedSections[key] ?? true);
    notifyListeners();
  }

  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();
    try {
      final allChars = await _characterRepo.getAll();
      _characterMap = {for (var c in allChars) c.id: c};

      _relSub = _relationshipService.watchAll().listen((allRelationships) {
        _relationships = allRelationships
            .where((rel) =>
                rel.character1Id == character.id ||
                rel.character2Id == character.id)
            .toList();
        notifyListeners();
      });

      _relatedNotes =
          await _noteRepo.getNotesForCharacter(character.key.toString());
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshNotes() async {
    try {
      _relatedNotes =
          await _noteRepo.getNotesForCharacter(character.key.toString());
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteCharacter() async {
    try {
      await _characterRepo.delete(character.key);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> duplicateCharacter() async {
    try {
      await _characterService.duplicateCharacter(character);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> exportToPdf(BuildContext context) async {
    try {
      await _characterService.exportToPdf(context, character);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> exportToJson(BuildContext context) async {
    try {
      await _characterService.exportToJson(context, character);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> copyToClipboard(BuildContext context) async {
    try {
      await ClipboardService.copyCharacterToClipboard(
        context: context,
        name: character.name,
        age: character.age,
        gender: character.gender,
        raceName: character.race?.name,
        biography: character.biography,
        appearance: character.appearance,
        personality: character.personality,
        abilities: character.abilities,
        other: character.other,
        customFields: character.customFields
            .map((f) => {'key': f.key, 'value': f.value})
            .toList(),
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteNote(Note note) async {
    try {
      await _noteRepo.delete(note.key);
      await refreshNotes();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _relSub?.cancel();
    super.dispose();
  }
}
