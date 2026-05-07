import 'dart:io';
import 'package:characterbook/data/models/custom_field_model.dart';
import 'package:characterbook/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:characterbook/data/models/character_model.dart';
import 'package:characterbook/data/models/note_model.dart';
import 'package:characterbook/data/models/race_model.dart';
import 'package:characterbook/data/models/template_model.dart';
import 'package:characterbook/data/models/relationship_model.dart';
import 'package:characterbook/data/models/export_pdf_settings_model.dart';
import 'package:characterbook/data/repositories/character_repository.dart';
import 'package:characterbook/data/repositories/note_repository.dart';
import 'package:characterbook/data/repositories/race_repository.dart';
import 'package:characterbook/data/repositories/template_repository.dart';
import 'package:characterbook/data/repositories/relationship_repository.dart';
import 'package:characterbook/services/backup_service.dart';

void main() {
  late Box<Character> charBox;
  late Box<Race> raceBox;
  late Box<Note> noteBox;
  late Box<QuestionnaireTemplate> templateBox;
  late Box<ExportPdfSettings> settingsBox;
  late Box<Relationship> relBox;
  late Box<bool> appSettingsBox;

  setUp(() async {
    final dir = await Directory.systemTemp.createTemp('hive_test_main');
    Hive.init(dir.path);

    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(CharacterAdapter());
    if (!Hive.isAdapterRegistered(1))
      Hive.registerAdapter(CustomFieldAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(NoteAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(RaceAdapter());
    if (!Hive.isAdapterRegistered(4))
      Hive.registerAdapter(QuestionnaireTemplateAdapter());
    if (!Hive.isAdapterRegistered(12))
      Hive.registerAdapter(RelationshipAdapter());

    charBox = await Hive.openBox<Character>('test_chars');
    raceBox = await Hive.openBox<Race>('test_races');
    noteBox = await Hive.openBox<Note>('test_notes');
    templateBox = await Hive.openBox<QuestionnaireTemplate>('test_templates');
    settingsBox = await Hive.openBox<ExportPdfSettings>('test_pdf_settings');
    relBox = await Hive.openBox<Relationship>('test_relationships');
    appSettingsBox = await Hive.openBox<bool>('test_app_settings');
  });

  tearDown(() async {
    await charBox.close();
    await raceBox.close();
    await noteBox.close();
    await templateBox.close();
    await settingsBox.close();
    await relBox.close();
    await appSettingsBox.close();
    for (final name in [
      'test_chars',
      'test_races',
      'test_notes',
      'test_templates',
      'test_pdf_settings',
      'test_relationships',
      'test_app_settings'
    ]) {
      Hive.deleteBoxFromDisk(name);
    }
  });

  testWidgets('CharacterBookApp создаёт BackupManager с RelationshipRepository',
      (tester) async {
    await tester.pumpWidget(
      CharacterBookApp(
        hiveInitialized: true,
        characterBox: charBox,
        raceBox: raceBox,
        noteBox: noteBox,
        templateBox: templateBox,
        settingsBox: settingsBox,
        relationshipBox: relBox,
        appSettingsBox: appSettingsBox,
      ),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(MaterialApp));
    final backupManager = Provider.of<BackupManager>(context, listen: false);

    expect(backupManager, isNotNull);
    expect(backupManager.characterRepo, isA<CharacterRepository>());
    expect(backupManager.noteRepo, isA<NoteRepository>());
    expect(backupManager.raceRepo, isA<RaceRepository>());
    expect(backupManager.templateRepo, isA<TemplateRepository>());
    expect(backupManager.relationshipRepo, isA<RelationshipRepository>());
  });

  testWidgets('LocalBackupService и CloudBackupService доступны',
      (tester) async {
    await tester.pumpWidget(
      CharacterBookApp(
        hiveInitialized: true,
        characterBox: charBox,
        raceBox: raceBox,
        noteBox: noteBox,
        templateBox: templateBox,
        settingsBox: settingsBox,
        relationshipBox: relBox,
        appSettingsBox: appSettingsBox,
      ),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(MaterialApp));

    final localBackup = Provider.of<LocalBackupService>(context, listen: false);
    final cloudBackup = Provider.of<CloudBackupService>(context, listen: false);

    expect(localBackup, isNotNull);
    expect(cloudBackup, isNotNull);
  });
}
