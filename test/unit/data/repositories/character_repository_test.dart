import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:characterbook/data/models/character_model.dart';
import 'package:characterbook/data/repositories/character_repository.dart';

import '../../../helpers/hive_test_utils.dart';

void main() {
  late CharacterRepository repository;
  late Box<Character> box;

  setUpAll(() async {
    await setUpTestHive();
  });

  setUp(() async {
    box = await Hive.openBox<Character>('test_characters');
    await box.clear();
    repository = CharacterRepositoryHive(box);
  });

  tearDown(() async {
    await box.close();
  });

  tearDownAll(() async {
    await tearDownTestHive();
  });

  group('CharacterRepository', () {
    test('save() adds character to box', () async {
      final character = Character(
        id: 'char-1',
        name: 'Geralt',
        age: 100,
        gender: 'Male',
        biography: 'Witcher',
      );
      await repository.save(character, key: character.id);
      expect(box.values.length, 1);
      expect(box.get('char-1')?.name, 'Geralt');
    });

    test('save() updates existing character', () async {
      final original = Character(id: 'char-1', name: 'Geralt');
      await repository.save(original, key: original.id);

      final updated = Character(id: 'char-1', name: 'Updated Geralt');
      await repository.save(updated, key: updated.id);

      expect(box.get('char-1')?.name, 'Updated Geralt');
      expect(box.values.length, 1);
    });

    test('delete() removes character', () async {
      final character = Character(id: 'char-1', name: 'Geralt');
      await repository.save(character, key: character.id);
      await repository.delete(character.id);
      expect(box.isEmpty, isTrue);
    });

    test('getAll() returns all characters', () async {
      final char1 = Character(id: '1', name: 'Geralt');
      final char2 = Character(id: '2', name: 'Ciri');
      final char3 = Character(id: '3', name: 'Yennefer');

      await repository.save(char1, key: char1.id);
      await repository.save(char2, key: char2.id);
      await repository.save(char3, key: char3.id);

      final all = await repository.getAll();
      expect(all.length, 3);
      expect(
          all.map((c) => c.name), containsAll(['Geralt', 'Ciri', 'Yennefer']));
    });

    test('clear() removes all characters', () async {
      final char1 = Character(id: '1', name: 'A');
      final char2 = Character(id: '2', name: 'B');
      await repository.save(char1, key: char1.id);
      await repository.save(char2, key: char2.id);
      await repository.clear();
      expect(await repository.getAll(), isEmpty);
    });

    test('reorder() changes order of items', () async {
      final char1 = Character(id: '1', name: 'A');
      final char2 = Character(id: '2', name: 'B');
      final char3 = Character(id: '3', name: 'C');

      await repository.save(char1, key: char1.id);
      await repository.save(char2, key: char2.id);
      await repository.save(char3, key: char3.id);

      await repository.reorder(0, 2);

      final ordered = await repository.getAll();
      expect(ordered[0].name, 'B');
      expect(ordered[1].name, 'C');
      expect(ordered[2].name, 'A');
    });
  });
}
