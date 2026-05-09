import 'package:characterbook/data/models/character_model.dart';
import 'package:characterbook/data/models/custom_field_model.dart';
import 'package:characterbook/data/models/race_model.dart';
import 'package:characterbook/data/models/template_model.dart';
import 'package:characterbook/services/word_export_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCharacter extends Mock implements Character {}

class MockRace extends Mock implements Race {}

void main() {
  group('CharacterWordExportService', () {
    late Character character;

    setUp(() {
      character = Character(
        id: 'test-id',
        name: 'Тестовый персонаж',
        age: 25,
        gender: 'мужской',
        biography: 'Тестовая биография.',
        personality: 'Спокойный',
        appearance: 'Высокий',
        abilities: 'Летать',
        other: 'Заметки',
        race: Race(id: 'race1', name: 'Эльф'),
        tags: ['герой', 'маг'],
        customFields: [
          CustomField('Оружие', 'Меч'),
          CustomField('Броня', 'Кольчуга'),
        ],
        imageBytes: null,
        referenceImageBytes: null,
        additionalImages: [],
      );
    });

    test('генерирует непустой документ для персонажа', () async {
      final service = WordExportService(character);
      final bytes = await service.generate();

      expect(bytes, isNotNull);
      expect(bytes, isNotEmpty);
      expect(bytes[0], 0x50);
      expect(bytes[1], 0x4B);
    });

    test('не падает если все текстовые поля пусты', () async {
      final emptyChar = Character.empty();
      final service = WordExportService(emptyChar);
      final bytes = await service.generate();

      expect(bytes, isNotEmpty);
    });
  });

  group('RaceWordExportService', () {
    late Race race;

    setUp(() {
      race = Race(
        id: 'r1',
        name: 'Эльфы',
        description: 'Древняя раса',
        biology: 'Долгожители',
        backstory: 'Легенды',
        tags: ['эльфы', 'древние'],
        additionalImages: [],
        logo: null,
      );
    });

    test('генерирует корректный DOCX для расы', () async {
      final service = RaceWordExportService(race);
      final bytes = await service.generate();

      expect(bytes, isNotEmpty);

      expect(bytes[0], 0x50);
      expect(bytes[1], 0x4B);
    });

    test('не падает при отсутствии логотипа', () async {
      final service = RaceWordExportService(race);

      await expectLater(service.generate(), completes);
    });
  });

  group('TemplateWordExportService', () {
    late QuestionnaireTemplate template;

    setUp(() {
      template = QuestionnaireTemplate(
        name: 'Фэнтези герой',
        standardFields: ['Имя', 'Возраст', 'Пол'],
        customFields: [
          CustomField('Класс', 'Воин'),
          CustomField('Уровень', '10'),
        ],
      );
    });

    test('создаёт документ со списком полей', () async {
      final service = TemplateWordExportService(template);
      final bytes = await service.generate();

      expect(bytes, isNotEmpty);
      expect(bytes[0], 0x50);
      expect(bytes[1], 0x4B);
    });

    test('документ не пуст даже без кастомных полей', () async {
      final simple = QuestionnaireTemplate(
        name: 'Простой',
        standardFields: ['Имя'],
        customFields: [],
      );
      final service = TemplateWordExportService(simple);
      final bytes = await service.generate();

      expect(bytes, isNotEmpty);
    });
  });
}
