import 'package:characterbook/data/repositories/relationship_repository.dart';
import 'package:characterbook/data/services/relationship_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:characterbook/data/models/character_model.dart';
import 'package:characterbook/data/repositories/character_repository.dart';
import 'package:characterbook/data/services/character_service.dart';

class MockCharacterRepository extends Mock implements CharacterRepository {}

void main() {
  late CharacterService service;
  late MockCharacterRepository mockRepo;

  setUp(() {
    mockRepo = MockCharacterRepository();
    //service = CharacterService(mockRepo, RelationshipService(RelationshipRepositoryHive(HiveBox())));
  });

  final testChar = Character(
    id: '1',
    name: 'Geralt',
    age: 100,
    gender: 'Male',
    biography: '',
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

  /*group('CharacterService', () {
    test('createCharacter() calls repository.save()', () async {
      when(() => mockRepo.save(any())).thenAnswer((_) async {});

      await service.createCharacter(testChar);

      verify(() => mockRepo.save(testChar)).called(1);
    });

    test('getCharacters() delegates to repository.getAll()', () {
      when(() => mockRepo.getAll(sortType: any(named: 'sortType')))
          .thenReturn([testChar]);

      final result = service.getCharacters(sortType: CharacterSortEnum.name);

      expect(result, hasLength(1));
      verify(() => mockRepo.getAll(sortType: CharacterSortEnum.name)).called(1);
    });

    test('deleteCharacter() removes character and its relationships', () async {
      // предположим, сервис также удаляет связи через RelationshipRepository
      // мокаем RelationshipRepository, если нужно
      when(() => mockRepo.delete('1')).thenAnswer((_) async {});

      await service.deleteCharacter('1');

      verify(() => mockRepo.delete('1')).called(1);
    });
  });*/
}
