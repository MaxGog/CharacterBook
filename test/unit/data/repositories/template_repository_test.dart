import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:characterbook/data/models/template_model.dart';
import 'package:characterbook/data/repositories/template_repository.dart';

import '../../../helpers/hive_test_utils.dart';

void main() {
  late TemplateRepository repository;
  late Box<QuestionnaireTemplate> box;

  setUpAll(() async {
    await setUpTestHive();
  });

  setUp(() async {
    box = await Hive.openBox<QuestionnaireTemplate>('test_templates');
    await box.clear(); // чистим
    repository = TemplateRepositoryHive(box);
  });

  tearDown(() async {
    await box.close();
  });

  tearDownAll(() async {
    await tearDownTestHive();
  });

  group('TemplateRepository', () {
    test('save() adds template using name as key', () async {
      final template = QuestionnaireTemplate(
        name: 'Basic',
        standardFields: ['name', 'age'],
      );
      await repository.save(template);
      expect(box.values.length, 1);
      expect(box.get('Basic')?.name, 'Basic');
    });

    test('save() overwrites template with same name', () async {
      final t1 = QuestionnaireTemplate(name: 'Basic', standardFields: ['name']);
      await repository.save(t1);
      final t2 = QuestionnaireTemplate(
          name: 'Basic', standardFields: ['name', 'class']);
      await repository.save(t2);
      final stored = box.get('Basic');
      expect(stored?.standardFields, ['name', 'class']);
      expect(box.values.length, 1);
    });

    test('delete() removes template by name', () async {
      final template = QuestionnaireTemplate(name: 'ToDelete');
      await repository.save(template);
      await repository.delete('ToDelete');
      expect(box.isEmpty, isTrue);
    });

    test('getAll() returns all templates', () async {
      final t1 = QuestionnaireTemplate(name: 'A');
      final t2 = QuestionnaireTemplate(name: 'B');
      await repository.save(t1);
      await repository.save(t2);
      final all = await repository.getAll();
      expect(all.length, 2);
      expect(all.map((t) => t.name), containsAll(['A', 'B']));
    });

    test('clear() removes all templates', () async {
      await repository.save(QuestionnaireTemplate(name: 'X'));
      await repository.save(QuestionnaireTemplate(name: 'Y'));
      await repository.clear();
      expect(await repository.getAll(), isEmpty);
    });

    test('initializeDefaultTemplates() populates empty box', () async {
      await repository.initializeDefaultTemplates();
      final all = await repository.getAll();
      expect(all.isNotEmpty, true);
      final names = all.map((t) => t.name).toSet();
      expect(names.contains('Dungeons & Dragons'), true);
      expect(names.contains('Минимальный шаблон'), true);
      expect(names.contains('Шаблон для рассказчиков'), true);
      expect(names.contains('Расширенный ролевой шаблон'), true);
      expect(names.contains('Ролевой шаблон по умолчанию'), true);
    });

    test('initializeDefaultTemplates() does nothing if box already has data',
        () async {
      await repository.save(QuestionnaireTemplate(name: 'Custom'));
      await repository.initializeDefaultTemplates();
      final all = await repository.getAll();
      expect(all.length, 1);
      expect(all.first.name, 'Custom');
    });

    test('reorder() does not throw', () async {
      await repository.save(QuestionnaireTemplate(name: 'A'));
      await repository.save(QuestionnaireTemplate(name: 'B'));
      await repository.reorder(0, 1);
    });
  });
}
