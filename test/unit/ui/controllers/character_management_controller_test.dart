import 'package:characterbook/data/models/character_model.dart';
import 'package:characterbook/data/models/custom_field_model.dart';
import 'package:characterbook/data/models/race_model.dart';
import 'package:characterbook/data/repositories/character_repository.dart';
import 'package:characterbook/data/repositories/race_repository.dart';
import 'package:characterbook/ui/controllers/character_management_controller.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeCharacterRepository implements CharacterRepository {
  final Map<dynamic, Character> _store = {};

  @override
  Stream<List<Character>> watchAll() => Stream.value(_store.values.toList());

  @override
  Future<List<Character>> getAll() async => _store.values.toList();

  @override
  Future<dynamic> save(Character character, {dynamic key}) async {
    if (key != null) {
      _store[key] = character;
    } else {
      final newKey = _store.length;
      _store[newKey] = character;
      key = newKey;
    }
    return key;
  }

  @override
  Future<void> delete(dynamic key) async => _store.remove(key);

  @override
  Future<void> reorder(int oldIndex, int newIndex) async {}

  @override
  Future<void> clear() async => _store.clear();
}

class FakeRaceRepository implements RaceRepository {
  final Map<dynamic, Race> _store = {};

  @override
  Stream<List<Race>> watchAll() => Stream.value(_store.values.toList());

  @override
  Future<List<Race>> getAll() async => _store.values.toList();

  @override
  Future<Race?> getById(String id) async {
    return _store.values.cast<Race?>().firstWhere(
          (r) => r?.id == id,
          orElse: () => null,
        );
  }

  @override
  Future<Race?> getByKey(dynamic key) async => _store[key];

  @override
  Future<dynamic> save(Race race, {dynamic key}) async {
    if (key != null) {
      _store[key] = race;
    } else {
      final newKey = _store.length;
      _store[newKey] = race;
      key = newKey;
    }
    return key;
  }

  @override
  Future<void> delete(dynamic key) async => _store.remove(key);

  @override
  Future<void> reorder(int oldIndex, int newIndex) async {}

  @override
  Future<void> clear() async => _store.clear();
}

void main() {
  late FakeCharacterRepository charRepo;
  late FakeRaceRepository raceRepo;

  setUp(() {
    charRepo = FakeCharacterRepository();
    raceRepo = FakeRaceRepository();
  });

  Future<void> settle() => Future.delayed(const Duration(milliseconds: 600));

  test('Creating a new character: custom fields do not duplicate the record',
      () async {
    final controller = CharacterManagementController(
      characterRepo: charRepo,
      raceRepo: raceRepo,
      character: null,
      template: null,
    );

    controller.updateName('Test Hero');
    controller.updateRace(Race(id: 'race1', name: 'Elf'));
    await controller.save();
    await settle();

    expect((await charRepo.getAll()).length, 1,
        reason:
            'After first save there must be exactly 1 character in storage');

    controller.setCustomFields([CustomField('skill', 'fire')]);
    controller.setCustomFields([
      CustomField('skill', 'ice'),
      CustomField('power', '50'),
    ]);

    await controller.save();
    await settle();

    final all = await charRepo.getAll();
    expect(all.length, 1,
        reason: 'After editing fields there should still be one character');

    final character = all.first;
    expect(character.name, 'Test Hero');
    expect(character.race?.name, 'Elf');
    expect(character.customFields.length, 2);
    expect(character.customFields[0].key, 'skill');
    expect(character.customFields[0].value, 'ice');
    expect(character.customFields[1].key, 'power');
    expect(character.customFields[1].value, '50');
  });

  test('Saving without a name returns false and does not create a record',
      () async {
    final controller = CharacterManagementController(
      characterRepo: charRepo,
      raceRepo: raceRepo,
      character: null,
      template: null,
    );
    controller.updateRace(Race(id: 'r2', name: 'Human'));
    final result = await controller.save();
    expect(result, isFalse);
    expect(await charRepo.getAll(), isEmpty,
        reason:
            'Without a name the character must not appear in the repository');
  });

  test('Saving without a race returns false and does not create a record',
      () async {
    final controller = CharacterManagementController(
      characterRepo: charRepo,
      raceRepo: raceRepo,
      character: null,
      template: null,
    );
    controller.updateName('No race');
    final result = await controller.save();
    expect(result, isFalse);
    expect(await charRepo.getAll(), isEmpty);
  });

  test('Multiple auto-saves do not produce duplicates', () async {
    final controller = CharacterManagementController(
      characterRepo: charRepo,
      raceRepo: raceRepo,
      character: null,
      template: null,
    );
    controller.updateName('Hero');
    controller.updateRace(Race(id: 'r3', name: 'Orc'));
    await controller.save();
    await settle();

    controller.updateName('Hero2');
    controller.updateAge(30);
    controller.updateGender('female');
    await settle();

    controller.setCustomFields([CustomField('power', '999')]);
    await controller.save();
    await settle();

    final all = await charRepo.getAll();
    expect(all.length, 1);
    expect(all.first.name, 'Hero2');
    expect(all.first.age, 30);
    expect(all.first.gender, 'female');
    expect(all.first.customFields.length, 1);
    expect(all.first.customFields.first.key, 'power');
    expect(all.first.customFields.first.value, '999');
  });
}
