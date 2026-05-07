import 'package:characterbook/data/models/character_model.dart';
import 'package:characterbook/data/models/custom_field_model.dart';import 'package:characterbook/data/models/export_pdf_settings_model.dart';

import 'package:characterbook/data/models/note_model.dart';
import 'package:characterbook/data/models/race_model.dart';
import 'package:characterbook/data/models/template_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static bool _isInitialized = false;

  static Future<void> initHive() async {
    if (!_isInitialized) {
      await Hive.initFlutter();
      _registerAdapters();
      _isInitialized = true;
    }
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
  }

  static Future<Box<T>> openBox<T>(String name) async {
    return await Hive.openBox<T>(name);
  }

  static Future<void> deleteBox(String name) async {
    await Hive.deleteBoxFromDisk(name);
  }
}
