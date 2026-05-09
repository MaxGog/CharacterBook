import 'package:characterbook/data/models/character_model.dart';
import 'package:characterbook/data/models/custom_event_model.dart';
import 'package:characterbook/data/models/custom_field_model.dart';
import 'package:characterbook/data/models/export_pdf_settings_model.dart';
import 'package:characterbook/data/models/note_model.dart';
import 'package:characterbook/data/models/race_model.dart';
import 'package:characterbook/data/models/relationship_model.dart';
import 'package:characterbook/data/models/template_model.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static bool _isInitialized = false;

  static Box<Character>? _characterBox;
  static Box<Race>? _raceBox;
  static Box<Note>? _noteBox;
  static Box<QuestionnaireTemplate>? _templateBox;
  static Box<ExportPdfSettings>? _settingsBox;
  static Box<Relationship>? _relationshipBox;
  static Box<CustomEvent>? _customEventBox;
  static Box<bool>? _appSettingsBox;

  static Box<Character>? get characterBox => _characterBox;
  static Box<Race>? get raceBox => _raceBox;
  static Box<Note>? get noteBox => _noteBox;
  static Box<QuestionnaireTemplate>? get templateBox => _templateBox;
  static Box<ExportPdfSettings>? get settingsBox => _settingsBox;
  static Box<Relationship>? get relationshipBox => _relationshipBox;
  static Box<CustomEvent>? get customEventBox => _customEventBox;
  static Box<bool>? get appSettingsBox => _appSettingsBox;

  static Future<void> initializeAll() async {
    if (!_isInitialized) {
      await Hive.initFlutter();
      _registerAdapters();
      _isInitialized = true;
    }
    _characterBox = await _openBoxWithRetry<Character>('characters');
    _raceBox = await _openBoxWithRetry<Race>('races');
    _noteBox = await _openBoxWithRetry<Note>('notes');
    _templateBox = await _openBoxWithRetry<QuestionnaireTemplate>('templates');
    _settingsBox = await _openBoxWithRetry<ExportPdfSettings>('pdf_settings');
    _relationshipBox = await _openBoxWithRetry<Relationship>('relationships');
    _customEventBox = await _openBoxWithRetry<CustomEvent>('custom_events');
    _appSettingsBox = await _openBoxWithRetry<bool>('app_settings');
  }

  static void setBoxesForTesting({
    Box<Character>? characterBox,
    Box<Race>? raceBox,
    Box<Note>? noteBox,
    Box<QuestionnaireTemplate>? templateBox,
    Box<ExportPdfSettings>? settingsBox,
    Box<Relationship>? relationshipBox,
    Box<CustomEvent>? customEventBox,
    Box<bool>? appSettingsBox,
  }) {
    _characterBox = characterBox;
    _raceBox = raceBox;
    _noteBox = noteBox;
    _templateBox = templateBox;
    _settingsBox = settingsBox;
    _relationshipBox = relationshipBox;
    _customEventBox = customEventBox;
    _appSettingsBox = appSettingsBox;
  }

  static void _registerAdapters() {
    if (!Hive.isAdapterRegistered(CharacterAdapter().typeId)) {
      Hive.registerAdapter(CharacterAdapter());
    }
    if (!Hive.isAdapterRegistered(NoteAdapter().typeId)) {
      Hive.registerAdapter(NoteAdapter());
    }
    if (!Hive.isAdapterRegistered(RaceAdapter().typeId)) {
      Hive.registerAdapter(RaceAdapter());
    }
    if (!Hive.isAdapterRegistered(QuestionnaireTemplateAdapter().typeId)) {
      Hive.registerAdapter(QuestionnaireTemplateAdapter());
    }
    if (!Hive.isAdapterRegistered(CustomFieldAdapter().typeId)) {
      Hive.registerAdapter(CustomFieldAdapter());
    }
    if (!Hive.isAdapterRegistered(ExportPdfSettingsAdapter().typeId)) {
      Hive.registerAdapter(ExportPdfSettingsAdapter());
    }
    if (!Hive.isAdapterRegistered(RelationshipAdapter().typeId)) {
      Hive.registerAdapter(RelationshipAdapter());
    }
    if (!Hive.isAdapterRegistered(CustomEventAdapter().typeId)) {
      Hive.registerAdapter(CustomEventAdapter());
    }
  }

  static Future<Box<T>> _openBoxWithRetry<T>(String name) async {
    try {
      return await Hive.openBox<T>(name);
    } catch (e) {
      debugPrint('Error opening box $name, deleting and retrying: $e');
      await Hive.deleteBoxFromDisk(name);
      return await Hive.openBox<T>(name);
    }
  }

  static Future<Box<T>> openBox<T>(String name) async {
    return await Hive.openBox<T>(name);
  }

  static Future<void> deleteBox(String name) async {
    await Hive.deleteBoxFromDisk(name);
  }
}
