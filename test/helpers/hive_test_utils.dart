import 'dart:io';
import 'package:hive/hive.dart';
import 'package:characterbook/data/models/character_model.dart';
import 'package:characterbook/data/models/race_model.dart';
import 'package:characterbook/data/models/note_model.dart';
import 'package:characterbook/data/models/relationship_model.dart';

Future<void> setUpTestHive() async {
  final dir = Directory.systemTemp.createTempSync();
  Hive.init(dir.path);

  Hive.registerAdapter(CharacterAdapter());
  Hive.registerAdapter(RaceAdapter());
  Hive.registerAdapter(NoteAdapter());
  Hive.registerAdapter(RelationshipAdapter());
}

Future<void> tearDownTestHive() async {
  await Hive.close();
}
