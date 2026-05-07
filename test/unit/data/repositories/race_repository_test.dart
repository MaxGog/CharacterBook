import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:characterbook/data/models/race_model.dart';
import 'package:characterbook/data/repositories/race_repository.dart';

import '../../../helpers/hive_test_utils.dart';

void main() {
  late RaceRepository repository;
  late Box<Race> box;

  setUpAll(() async {
    await setUpTestHive();
  });

  setUp(() async {
    box = await Hive.openBox<Race>('test_races');
    await box.clear();
    repository = RaceRepositoryHive(box);
  });

  tearDown(() async {
    await box.close();
  });

  tearDownAll(() async {
    await tearDownTestHive();
  });

  group('RaceRepository', () {
    test('save() adds race to box', () async {
      final race = Race(id: 'race-1', name: 'Elf');
      await repository.save(race, key: race.id);
      expect(box.values.length, 1);
      expect(box.get('race-1')?.name, 'Elf');
    });

    test('save() updates existing race', () async {
      final original = Race(id: 'race-1', name: 'Elf');
      await repository.save(original, key: original.id);

      final updated = Race(id: 'race-1', name: 'High Elf');
      await repository.save(updated, key: updated.id);

      expect(box.get('race-1')?.name, 'High Elf');
      expect(box.values.length, 1);
    });

    test('delete() removes race', () async {
      final race = Race(id: 'race-1', name: 'Dwarf');
      await repository.save(race, key: race.id);
      await repository.delete(race.id);
      expect(box.isEmpty, isTrue);
    });

    test('getAll() returns all races', () async {
      final r1 = Race(id: '1', name: 'Elf');
      final r2 = Race(id: '2', name: 'Orc');
      await repository.save(r1, key: r1.id);
      await repository.save(r2, key: r2.id);
      final all = await repository.getAll();
      expect(all.length, 2);
      expect(all.map((r) => r.name), containsAll(['Elf', 'Orc']));
    });

    test('getById() finds race', () async {
      final race = Race(id: 'race-x', name: 'Dragon');
      await repository.save(race, key: race.id);
      final found = await repository.getById('race-x');
      expect(found?.name, 'Dragon');
    });

    test('clear() removes all races', () async {
      final r1 = Race(id: '1', name: 'A');
      final r2 = Race(id: '2', name: 'B');
      await repository.save(r1, key: r1.id);
      await repository.save(r2, key: r2.id);
      await repository.clear();
      expect(await repository.getAll(), isEmpty);
    });

    test('reorder() changes order', () async {
      final rA = Race(id: 'a', name: 'A');
      final rB = Race(id: 'b', name: 'B');
      final rC = Race(id: 'c', name: 'C');
      await repository.save(rA, key: rA.id);
      await repository.save(rB, key: rB.id);
      await repository.save(rC, key: rC.id);

      await repository.reorder(0, 2);
      final ordered = await repository.getAll();
      expect(ordered[0].name, 'B');
      expect(ordered[1].name, 'C');
      expect(ordered[2].name, 'A');
    });
  });
}
