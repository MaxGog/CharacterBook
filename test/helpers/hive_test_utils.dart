import 'dart:io';
import 'package:hive/hive.dart';
import 'package:characterbook/data/models/character_model.dart';
import 'package:characterbook/data/models/race_model.dart';
import 'package:characterbook/data/models/note_model.dart';
import 'package:characterbook/data/models/relationship_model.dart';
import 'package:characterbook/data/models/template_model.dart';
import 'package:characterbook/data/models/custom_field_model.dart';

String? _tempDirPath;

Future<void> setUpTestHive() async {
  final dir = Directory.systemTemp.createTempSync();
  _tempDirPath = dir.path;
  Hive.init(_tempDirPath!);

  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(CharacterAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(NoteAdapter());
  }
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(RaceAdapter());
  }
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(QuestionnaireTemplateAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(CustomFieldAdapter());
  }
  if (!Hive.isAdapterRegistered(12)) {
    Hive.registerAdapter(RelationshipAdapter());
  }
}

Future<void> tearDownTestHive() async {
  if (_tempDirPath != null) {
    final dir = Directory(_tempDirPath!);
    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
  }
}
