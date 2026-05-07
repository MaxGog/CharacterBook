import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:characterbook/data/models/relationship_model.dart';
import 'package:characterbook/data/repositories/relationship_repository.dart';

import '../../../helpers/hive_test_utils.dart';

void main() {
  late RelationshipRepository repository;
  late Box<Relationship> box;

  setUpAll(() async {
    await setUpTestHive();
  });

  setUp(() async {
    box = await Hive.openBox<Relationship>('test_relationships');
    await box.clear();
    repository = RelationshipRepositoryHive(box);
  });

  tearDown(() async {
    await box.close();
  });

  tearDownAll(() async {
    await tearDownTestHive();
  });

  group('RelationshipRepository', () {
    test('save() adds relationship to box', () async {
      final rel = Relationship(
        id: 'rel-1',
        character1Id: 'char1',
        character2Id: 'char2',
        name: 'Friends',
      );
      await repository.save(rel, key: rel.id);
      expect(box.values.length, 1);
      expect(box.get('rel-1')?.name, 'Friends');
    });

    test('save() updates existing relationship', () async {
      final original = Relationship(
        id: 'rel-1',
        character1Id: 'char1',
        character2Id: 'char2',
        name: 'Friends',
      );
      await repository.save(original, key: original.id);

      final updated = Relationship(
        id: 'rel-1',
        character1Id: 'char1',
        character2Id: 'char2',
        name: 'Best Friends',
      );
      await repository.save(updated, key: updated.id);

      expect(box.get('rel-1')?.name, 'Best Friends');
      expect(box.values.length, 1);
    });

    test('delete() removes relationship', () async {
      final rel = Relationship(
        id: 'rel-1',
        character1Id: 'c1',
        character2Id: 'c2',
      );
      await repository.save(rel, key: rel.id);
      await repository.delete(rel.id);
      expect(box.isEmpty, isTrue);
    });

    test('getAll() returns all relationships', () async {
      final r1 = Relationship(id: '1', character1Id: 'a', character2Id: 'b');
      final r2 = Relationship(id: '2', character1Id: 'c', character2Id: 'd');
      await repository.save(r1, key: r1.id);
      await repository.save(r2, key: r2.id);
      final all = await repository.getAll();
      expect(all.length, 2);
    });

    test('clear() removes all relationships', () async {
      final r1 = Relationship(id: '1', character1Id: 'x', character2Id: 'y');
      final r2 = Relationship(id: '2', character1Id: 'z', character2Id: 'w');
      await repository.save(r1, key: r1.id);
      await repository.save(r2, key: r2.id);
      await repository.clear();
      expect(await repository.getAll(), isEmpty);
    });
  });
}
