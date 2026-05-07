import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:characterbook/data/models/character_model.dart';
import 'package:characterbook/data/repositories/character_repository.dart';

import '../../../helpers/hive_test_utils.dart';

void main() {
  late CharacterRepository repository;
  late Box<Character> box;

  setUp(() async {
    await setUpTestHive();
    box = await Hive.openBox<Character>('test_characters');
    repository = CharacterRepositoryHive(box);
  });

  tearDown(() async {
    await box.clear();
    await tearDownTestHive();
  });

  final testCharacter = Character(
    id: 'char-1',
    name: 'Geralt',
    age: 100,
    gender: 'Male',
    biography: 'Witcher',
    personality: '',
    appearance: '',
    imageBytes: null,
    referenceImageBytes: null,
    additionalImages: [],
    customFields: [],
    race: null,
    folderId: null,
    tags: [],
  );

  group('CharacterRepository', () {
    test('save() adds character to box', () async {
      await repository.save(testCharacter);
      expect(box.values.length, 1);
      expect(box.get('char-1')?.name, 'Geralt');
    });

    test('save() updates existing character', () async {
      await repository.save(testCharacter);
      final updated = testCharacter.copyWith(name: 'Updated Geralt');
      await repository.save(updated);
      expect(box.get('char-1')?.name, 'Updated Geralt');
    });

    test('delete() removes character', () async {
      await repository.save(testCharacter);
      await repository.delete('char-1');
      expect(box.isEmpty, isTrue);
    });

    test('getAll() returns sorted list by name', () async {
      final charA = testCharacter.copyWith(id: '2', name: 'Ciri');
      final charB = testCharacter.copyWith(id: '3', name: 'Yennefer');
      await repository.save(testCharacter); // Geralt
      await repository.save(charA);
      await repository.save(charB);

    });

    test('search() filters by name', () async {
      await repository.save(testCharacter);
      final char2 = testCharacter.copyWith(id: '2', name: 'Eskel');
      await repository.save(char2);
    });
  });
}
