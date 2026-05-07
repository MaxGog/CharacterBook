import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:characterbook/data/models/folder_model.dart';
import 'package:characterbook/data/repositories/folder_repository.dart';

import '../../../helpers/hive_test_utils.dart';

void main() {
  late FolderRepository repository;
  late Box<Folder> box;

  setUp(() async {
    await setUpTestHive();
    box = await Hive.openBox<Folder>('test_folders');
    repository = FolderRepositoryHive(box);
  });

  tearDown(() async {
    await box.clear();
    await tearDownTestHive();
  });

  final testFolder = Folder(
    id: 'folder-1',
    name: 'Main Characters',
    type: FolderType.character,
    parentId: null,
    contentIds: [],
    colorValue: null,
  );

  test('save() and getById()', () async {
    await repository.save(testFolder);
    final fetched = repository.getById('folder-1');
    expect(fetched, 'Main Characters');
  });

  test('getFoldersByType() filters by type', () async {
    await repository.save(testFolder);
    final raceFolder = testFolder.copyWith(
      id: 'folder-2',
      type: FolderType.race,
      name: 'Races',
    );
    await repository.save(raceFolder);

    final characterFolders = repository.getByType(FolderType.character);
    expect(characterFolders, 1);
  });

  test('delete() removes folder', () async {
    await repository.save(testFolder);
    await repository.delete('folder-1');
    expect(box.isEmpty, true);
  });
}
