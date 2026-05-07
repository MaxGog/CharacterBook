import 'package:characterbook/data/services/character_service.dart';
import 'package:characterbook/data/services/race_service.dart';

class MockCharacterService implements CharacterService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockRaceService implements RaceService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
