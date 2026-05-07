import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:characterbook/data/models/character_model.dart';
import 'package:characterbook/data/models/note_model.dart';
import 'package:characterbook/data/models/race_model.dart';
import 'package:characterbook/data/models/template_model.dart';
import 'package:characterbook/data/models/relationship_model.dart';
import 'package:characterbook/data/repositories/character_repository.dart';
import 'package:characterbook/data/repositories/note_repository.dart';
import 'package:characterbook/data/repositories/race_repository.dart';
import 'package:characterbook/data/repositories/template_repository.dart';
import 'package:characterbook/data/repositories/relationship_repository.dart';
import 'package:characterbook/services/backup_service.dart';
import '../../../helpers/hive_test_utils.dart';

void main() {
  late BackupManager backupManager;
  late CharacterRepository characterRepo;
  late NoteRepository noteRepo;
  late RaceRepository raceRepo;
  late TemplateRepository templateRepo;
  late RelationshipRepository relationshipRepo;

  late Box<Character> charBox;
  late Box<Note> noteBox;
  late Box<Race> raceBox;
  late Box<QuestionnaireTemplate> templateBox;
  late Box<Relationship> relBox;

  setUpAll(() async {
    await setUpTestHive();
  });

  setUp(() async {
    charBox = await Hive.openBox<Character>('test_characters_backup');
    noteBox = await Hive.openBox<Note>('test_notes_backup');
    raceBox = await Hive.openBox<Race>('test_races_backup');
    templateBox =
        await Hive.openBox<QuestionnaireTemplate>('test_templates_backup');
    relBox = await Hive.openBox<Relationship>('test_relationships_backup');

    await charBox.clear();
    await noteBox.clear();
    await raceBox.clear();
    await templateBox.clear();
    await relBox.clear();

    characterRepo = CharacterRepositoryHive(charBox);
    noteRepo = NoteRepositoryHive(noteBox);
    raceRepo = RaceRepositoryHive(raceBox);
    templateRepo = TemplateRepositoryHive(templateBox);
    relationshipRepo = RelationshipRepositoryHive(relBox);

    backupManager = BackupManager(
      characterRepo: characterRepo,
      noteRepo: noteRepo,
      raceRepo: raceRepo,
      templateRepo: templateRepo,
      relationshipRepo: relationshipRepo,
    );
  });

  tearDown(() async {
    await charBox.close();
    await noteBox.close();
    await raceBox.close();
    await templateBox.close();
    await relBox.close();
  });

  tearDownAll(() async {
    await tearDownTestHive();
  });

  group('BackupManager', () {
    test('getBackupData returns all data types including relationships',
        () async {
      final char = Character(id: 'c1', name: 'Hero');
      await characterRepo.save(char, key: char.id);

      final note = Note(id: 'n1', title: 'Note1', content: '', folderId: null);
      await noteRepo.save(note, key: note.id);

      final race = Race(id: 'r1', name: 'Elf');
      await raceRepo.save(race, key: race.id);

      final template =
          QuestionnaireTemplate(name: 'Basic', standardFields: ['name']);
      await templateRepo.save(template);

      final rel = Relationship(
          id: 'rel1', character1Id: 'c1', character2Id: 'c2', name: 'Friends');
      await relationshipRepo.save(rel, key: rel.id);

      final data = await backupManager.getBackupData();

      expect(
          data.keys,
          containsAll(
              ['characters', 'notes', 'races', 'templates', 'relationships']));
      expect(data['characters']!.length, 1);
      expect((data['characters']![0] as Character).id, 'c1');
      expect(data['notes']!.length, 1);
      expect(data['races']!.length, 1);
      expect(data['templates']!.length, 1);
      expect(data['relationships']!.length, 1);
      expect((data['relationships']![0] as Relationship).id, 'rel1');
    });

    test('restoreFromBackupData restores all types including relationships',
        () async {
      final char = Character(id: 'c1', name: 'Hero');
      await characterRepo.save(char, key: char.id);
      final note = Note(id: 'n1', title: 'Test', content: '', folderId: null);
      await noteRepo.save(note, key: note.id);
      final race = Race(id: 'r1', name: 'Dwarf');
      await raceRepo.save(race, key: race.id);
      final template = QuestionnaireTemplate(name: 'T1', standardFields: []);
      await templateRepo.save(template);
      final rel = Relationship(
          id: 'rel1', character1Id: 'c1', character2Id: 'c2', name: 'Friend');
      await relationshipRepo.save(rel, key: rel.id);

      final rawData = await backupManager.getBackupData();

      final jsonString = jsonEncode(rawData);
      final importData = jsonDecode(jsonString) as Map<String, dynamic>;

      await characterRepo.clear();
      await noteRepo.clear();
      await raceRepo.clear();
      await templateRepo.clear();
      await relationshipRepo.clear();

      await backupManager.restoreFromBackupData(importData);

      final chars = await characterRepo.getAll();
      expect(chars.length, 1);
      expect(chars.first.name, 'Hero');

      final notes = await noteRepo.getAll();
      expect(notes.length, 1);
      expect(notes.first.title, 'Test');

      final races = await raceRepo.getAll();
      expect(races.length, 1);
      expect(races.first.name, 'Dwarf');

      final templates = await templateRepo.getAll();
      expect(templates.length, 1);
      expect(templates.first.name, 'T1');

      final relationships = await relationshipRepo.getAll();
      expect(relationships.length, 1);
      expect(relationships.first.name, 'Friend');
    });

    test('restoreFromBackupData clears all data before restoring', () async {
      final charOld = Character(id: 'old', name: 'Old');
      await characterRepo.save(charOld, key: charOld.id);
      final relOld =
          Relationship(id: 'oldRel', character1Id: 'a', character2Id: 'b');
      await relationshipRepo.save(relOld, key: relOld.id);

      final newData = {
        'characters': [Character(id: 'new', name: 'New').toJson()],
        'notes': <Map>[],
        'races': <Map>[],
        'templates': <Map>[],
        'relationships': <Map>[],
      };

      await backupManager.restoreFromBackupData(newData);

      final chars = await characterRepo.getAll();
      expect(chars.length, 1);
      expect(chars.first.name, 'New');

      final rels = await relationshipRepo.getAll();
      expect(rels.length, 0);
    });

    test(
        'restoreFromBackupData handles missing relationships key gracefully for old backups',
        () async {
      final oldFormatData = {
        'characters': [Character(id: 'c1', name: 'OldHero').toJson()],
        'notes': [],
        'races': [],
        'templates': [],
      };

      final rel = Relationship(id: 'r1', character1Id: 'x', character2Id: 'y');
      await relationshipRepo.save(rel, key: rel.id);

      await backupManager.restoreFromBackupData(oldFormatData);

      final relationships = await relationshipRepo.getAll();
      expect(relationships.length, 0);

      final chars = await characterRepo.getAll();
      expect(chars.length, 1);
      expect(chars.first.name, 'OldHero');
    });

    test('restoreFromBackupData with empty data clears all', () async {
      await characterRepo.save(Character(id: '1', name: 'A'), key: '1');
      await relationshipRepo.save(
          Relationship(id: 'r1', character1Id: '1', character2Id: '2'),
          key: 'r1');

      final emptyData = {
        'characters': [],
        'notes': [],
        'races': [],
        'templates': [],
        'relationships': [],
      };

      await backupManager.restoreFromBackupData(emptyData);

      expect((await characterRepo.getAll()).length, 0);
      expect((await relationshipRepo.getAll()).length, 0);
    });
  });
}
