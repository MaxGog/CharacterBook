import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:hive/hive.dart';
import '../models/character_model.dart';
import '../models/note_model.dart';
import '../models/race_model.dart';

class CloudBackupService {
  static const List<String> _scopes = [drive.DriveApi.driveFileScope];
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: _scopes);
  drive.DriveApi? _driveApi;

  Future<void> exportAllToCloud(BuildContext context) async {
    try {
      final charactersBox = Hive.box<Character>('characters');
      final characters = charactersBox.values.toList();
      final charactersJson = jsonEncode(characters.map((c) => c.toJson()).toList());

      final notesBox = Hive.box<Note>('notes');
      final notes = notesBox.values.toList();
      final notesJson = jsonEncode(notes.map((n) => n.toJson()).toList());

      final racesBox = Hive.box<Race>('races');
      final races = racesBox.values.toList();
      final racesJson = jsonEncode(races.map((r) => r.toJson()).toList());

      final backupData = {
        'characters': characters,
        'notes': notes,
        'races': races,
      };
      final backupJson = jsonEncode(backupData);

      await _exportToGoogleDrive(backupJson, 'characterbook_backup');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Полная резервная копия успешно создана в Google Drive'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при создании резервной копии: $e')),
        );
      }
    }
  }

  Future<void> exportCharactersToCloud(BuildContext context) async {
    try {
      final box = Hive.box<Character>('characters');
      final characters = box.values.toList();
      final jsonStr = jsonEncode(characters.map((c) => c.toJson()).toList());

      await _exportToGoogleDrive(jsonStr, 'characters_backup');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Резервная копия персонажей успешно создана')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при создании резервной копии персонажей: $e')),
        );
      }
    }
  }

  Future<void> exportNotesToCloud(BuildContext context) async {
    try {
      final box = Hive.box<Note>('notes');
      final notes = box.values.toList();
      final jsonStr = jsonEncode(notes.map((n) => n.toJson()).toList());

      await _exportToGoogleDrive(jsonStr, 'notes_backup');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Резервная копия заметок успешно создана')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при создании резервной копии заметок: $e')),
        );
      }
    }
  }

  Future<void> exportRacesToCloud(BuildContext context) async {
    try {
      final box = Hive.box<Race>('races');
      final races = box.values.toList();
      final jsonStr = jsonEncode(races.map((r) => r.toJson()).toList());

      await _exportToGoogleDrive(jsonStr, 'races_backup');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Резервная копия рас успешно создана')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при создании резервной копии рас: $e')),
        );
      }
    }
  }

  Future<void> _exportToGoogleDrive(String jsonStr, String prefix) async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) throw Exception('Авторизация отменена');

      final client = await _googleSignIn.authenticatedClient();
      if (client == null) throw Exception('Не удалось получить клиент для API');

      _driveApi = drive.DriveApi(client);

      final fileMetadata = drive.File()
        ..name = '${prefix}_${DateTime.now().toIso8601String()}.json'
        ..mimeType = 'application/json';

      final bytes = Uint8List.fromList(utf8.encode(jsonStr));
      final media = drive.Media(Stream.value(bytes), bytes.length);

      await _driveApi!.files.create(
        fileMetadata,
        uploadMedia: media,
      );
    } catch (e) {
      throw Exception('Ошибка при экспорте в Google Drive: $e');
    }
  }

  Future<void> importAllFromCloud(BuildContext context) async {
    try {
      final jsonStr = await _importFromGoogleDrive('characterbook_backup');
      final Map<String, dynamic> data = jsonDecode(jsonStr);

      // Импорт рас (должен быть перед персонажами, так как персонажи ссылаются на расы)
      final racesBox = Hive.box<Race>('races');
      await racesBox.clear();
      final List<dynamic> racesJson = data['races'] ?? [];
      for (final json in racesJson) {
        await racesBox.add(Race.fromJson(json));
      }

      final charactersBox = Hive.box<Character>('characters');
      await charactersBox.clear();
      final List<dynamic> charactersJson = data['characters'] ?? [];
      for (final json in charactersJson) {
        await charactersBox.add(Character.fromJson(json));
      }

      final notesBox = Hive.box<Note>('notes');
      await notesBox.clear();
      final List<dynamic> notesJson = data['notes'] ?? [];
      for (final json in notesJson) {
        await notesBox.add(Note.fromJson(json));
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Успешно восстановлено ${charactersJson.length} персонажей, '
                  '${notesJson.length} заметок и ${racesJson.length} рас',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при восстановлении данных: $e')),
        );
      }
    }
  }

  Future<void> importCharactersFromCloud(BuildContext context) async {
    try {
      final jsonStr = await _importFromGoogleDrive('characters_backup');

      final box = Hive.box<Character>('characters');
      await box.clear();

      final List<dynamic> jsonList = jsonDecode(jsonStr);
      for (final json in jsonList) {
        await box.add(Character.fromJson(json));
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Успешно восстановлено ${jsonList.length} персонажей')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при восстановлении персонажей: $e')),
        );
      }
    }
  }

  Future<void> importNotesFromCloud(BuildContext context) async {
    try {
      final jsonStr = await _importFromGoogleDrive('notes_backup');

      final box = Hive.box<Note>('notes');
      await box.clear();

      final List<dynamic> jsonList = jsonDecode(jsonStr);
      for (final json in jsonList) {
        await box.add(Note.fromJson(json));
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Успешно восстановлено ${jsonList.length} заметок')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при восстановлении заметок: $e')),
        );
      }
    }
  }

  Future<void> importRacesFromCloud(BuildContext context) async {
    try {
      final jsonStr = await _importFromGoogleDrive('races_backup');

      final box = Hive.box<Race>('races');
      await box.clear();

      final List<dynamic> jsonList = jsonDecode(jsonStr);
      for (final json in jsonList) {
        await box.add(Race.fromJson(json));
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Успешно восстановлено ${jsonList.length} рас')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при восстановлении рас: $e')),
        );
      }
    }
  }

  Future<String> _importFromGoogleDrive(String prefix) async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) throw Exception('Авторизация отменена');

      final client = await _googleSignIn.authenticatedClient();
      if (client == null) throw Exception('Не удалось получить клиент для API');

      _driveApi = drive.DriveApi(client);

      final files = await _driveApi!.files.list(
        q: "name contains '$prefix' and mimeType='application/json'",
        orderBy: 'createdTime desc',
        pageSize: 1,
      );

      if (files.files == null || files.files!.isEmpty) {
        throw Exception('Резервные копии не найдены');
      }

      final file = files.files!.first;
      final response = await _driveApi!.files.get(
        file.id!,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      final bytes = await _readStream(response.stream);
      return utf8.decode(bytes);
    } catch (e) {
      throw Exception('Ошибка при импорте из Google Drive: $e');
    }
  }

  Future<Uint8List> _readStream(Stream<List<int>> stream) async {
    final bytesBuilder = BytesBuilder();
    await for (final chunk in stream) {
      bytesBuilder.add(chunk);
    }
    return bytesBuilder.toBytes();
  }
}

/*class CloudBackupService {
  static const List<String> _scopes = [drive.DriveApi.driveFileScope];
  static const String _backupFolderName = 'CharacterBookBackups';
  static const String _backupFileName = 'characterbook_data.json';

  final GoogleSignIn _googleSignIn;
  drive.DriveApi? _driveApi;
  String? _backupFolderId;

  CloudBackupService(this._googleSignIn);

  Future<void> autoSyncOnLogin(BuildContext context) async {
    try {
      final isSignedIn = await _googleSignIn.isSignedIn();
      if (!isSignedIn) return;

      await _initializeDriveApi();
      await _ensureBackupFolderExists();

      final backupExists = await _checkBackupExists();
      if (backupExists) {
        await importAllFromCloud(context);
      } else {
        await exportAllToCloud(context);
      }
    } catch (e) {
      debugPrint('Ошибка при автоматической синхронизации: $e');
    }
  }

  Future<void> _initializeDriveApi() async {
    final client = await _googleSignIn.authenticatedClient();
    if (client == null) throw Exception('Не удалось получить клиент для API');
    _driveApi = drive.DriveApi(client);
  }

  Future<void> _ensureBackupFolderExists() async {
    if (_backupFolderId != null) return;

    final query = "mimeType='application/vnd.google-apps.folder' and name='$_backupFolderName' and trashed=false";
    final response = await _driveApi!.files.list(q: query);

    if (response.files != null && response.files!.isNotEmpty) {
      _backupFolderId = response.files!.first.id;
    } else {
      final folder = drive.File()
        ..name = _backupFolderName
        ..mimeType = 'application/vnd.google-apps.folder';

      final createdFolder = await _driveApi!.files.create(folder);
      _backupFolderId = createdFolder.id;
    }
  }

  Future<bool> _checkBackupExists() async {
    final query = "name='$_backupFileName' and '$_backupFolderId' in parents and trashed=false";
    final response = await _driveApi!.files.list(q: query);
    return response.files != null && response.files!.isNotEmpty;
  }

  Future<void> exportAllToCloud(BuildContext context) async {
    try {
      await _initializeDriveApi();
      await _ensureBackupFolderExists();

      final charactersBox = Hive.box<Character>('characters');
      final notesBox = Hive.box<Note>('notes');
      final racesBox = Hive.box<Race>('races');

      final backupData = {
        'characters': charactersBox.values.map((c) => c.toJson()).toList(),
        'notes': notesBox.values.map((n) => n.toJson()).toList(),
        'races': racesBox.values.map((r) => r.toJson()).toList(),
      };

      final backupJson = jsonEncode(backupData);
      await _uploadToDrive(backupJson);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Данные успешно синхронизированы с Google Drive'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка синхронизации: $e')),
        );
      }
    }
  }

  Future<void> _uploadToDrive(String jsonStr) async {
    final query = "name='$_backupFileName' and '$_backupFolderId' in parents and trashed=false";
    final response = await _driveApi!.files.list(q: query);

    final bytes = Uint8List.fromList(utf8.encode(jsonStr));
    final media = drive.Media(Stream.value(bytes), bytes.length);

    if (response.files != null && response.files!.isNotEmpty) {
      final fileId = response.files!.first.id!;
      await _driveApi!.files.update(
        drive.File()..name = _backupFileName,
        fileId,
        uploadMedia: media,
      );
    } else {
      // Создаем новый файл
      final fileMetadata = drive.File()
        ..name = _backupFileName
        ..mimeType = 'application/json'
        ..parents = [_backupFolderId!];

      await _driveApi!.files.create(
        fileMetadata,
        uploadMedia: media,
      );
    }
  }

  Future<void> importAllFromCloud(BuildContext context) async {
    try {
      await _initializeDriveApi();
      await _ensureBackupFolderExists();

      final jsonStr = await _downloadFromDrive();
      final Map<String, dynamic> data = jsonDecode(jsonStr);

      final racesBox = Hive.box<Race>('races');
      await racesBox.clear();
      final List<dynamic> racesJson = data['races'] ?? [];
      for (final json in racesJson) {
        await racesBox.add(Race.fromJson(json));
      }

      final charactersBox = Hive.box<Character>('characters');
      await charactersBox.clear();
      final List<dynamic> charactersJson = data['characters'] ?? [];
      for (final json in charactersJson) {
        await charactersBox.add(Character.fromJson(json));
      }

      final notesBox = Hive.box<Note>('notes');
      await notesBox.clear();
      final List<dynamic> notesJson = data['notes'] ?? [];
      for (final json in notesJson) {
        await notesBox.add(Note.fromJson(json));
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Данные успешно восстановлены: '
                  '${charactersJson.length} персонажей, '
                  '${notesJson.length} заметок, '
                  '${racesJson.length} рас',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при восстановлении данных: $e')),
        );
      }
    }
  }

  Future<String> _downloadFromDrive() async {
    final query = "name='$_backupFileName' and '$_backupFolderId' in parents and trashed=false";
    final response = await _driveApi!.files.list(q: query);

    if (response.files == null || response.files!.isEmpty) {
      throw Exception('Резервная копия не найдена');
    }

    final fileId = response.files!.first.id!;
    final media = await _driveApi!.files.get(
      fileId,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;

    final bytes = await _readStream(media.stream);
    return utf8.decode(bytes);
  }

  Future<Uint8List> _readStream(Stream<List<int>> stream) async {
    final bytesBuilder = BytesBuilder();
    await for (final chunk in stream) {
      bytesBuilder.add(chunk);
    }
    return bytesBuilder.toBytes();
  }

  Future<void> exportCharactersToCloud(BuildContext context) async {
    try {
      final box = Hive.box<Character>('characters');
      final characters = box.values.toList();
      final jsonStr = jsonEncode(characters.map((c) => c.toJson()).toList());

      await _exportToGoogleDrive(jsonStr, 'characters_backup');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Резервная копия персонажей успешно создана')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при создании резервной копии персонажей: $e')),
        );
      }
    }
  }

  Future<void> exportNotesToCloud(BuildContext context) async {
    try {
      final box = Hive.box<Note>('notes');
      final notes = box.values.toList();
      final jsonStr = jsonEncode(notes.map((n) => n.toJson()).toList());

      await _exportToGoogleDrive(jsonStr, 'notes_backup');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Резервная копия заметок успешно создана')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при создании резервной копии заметок: $e')),
        );
      }
    }
  }

  Future<void> exportRacesToCloud(BuildContext context) async {
    try {
      final box = Hive.box<Race>('races');
      final races = box.values.toList();
      final jsonStr = jsonEncode(races.map((r) => r.toJson()).toList());

      await _exportToGoogleDrive(jsonStr, 'races_backup');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Резервная копия рас успешно создана')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при создании резервной копии рас: $e')),
        );
      }
    }
  }

  Future<void> _exportToGoogleDrive(String jsonStr, String prefix) async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) throw Exception('Авторизация отменена');

      final client = await _googleSignIn.authenticatedClient();
      if (client == null) throw Exception('Не удалось получить клиент для API');

      _driveApi = drive.DriveApi(client);

      final fileMetadata = drive.File()
        ..name = '${prefix}_${DateTime.now().toIso8601String()}.json'
        ..mimeType = 'application/json';

      final bytes = Uint8List.fromList(utf8.encode(jsonStr));
      final media = drive.Media(Stream.value(bytes), bytes.length);

      await _driveApi!.files.create(
        fileMetadata,
        uploadMedia: media,
      );
    } catch (e) {
      throw Exception('Ошибка при экспорте в Google Drive: $e');
    }
  }

  Future<void> importCharactersFromCloud(BuildContext context) async {
    try {
      final jsonStr = await _importFromGoogleDrive('characters_backup');

      final box = Hive.box<Character>('characters');
      await box.clear();

      final List<dynamic> jsonList = jsonDecode(jsonStr);
      for (final json in jsonList) {
        await box.add(Character.fromJson(json));
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Успешно восстановлено ${jsonList.length} персонажей')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при восстановлении персонажей: $e')),
        );
      }
    }
  }

  Future<void> importNotesFromCloud(BuildContext context) async {
    try {
      final jsonStr = await _importFromGoogleDrive('notes_backup');

      final box = Hive.box<Note>('notes');
      await box.clear();

      final List<dynamic> jsonList = jsonDecode(jsonStr);
      for (final json in jsonList) {
        await box.add(Note.fromJson(json));
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Успешно восстановлено ${jsonList.length} заметок')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при восстановлении заметок: $e')),
        );
      }
    }
  }

  Future<void> importRacesFromCloud(BuildContext context) async {
    try {
      final jsonStr = await _importFromGoogleDrive('races_backup');

      final box = Hive.box<Race>('races');
      await box.clear();

      final List<dynamic> jsonList = jsonDecode(jsonStr);
      for (final json in jsonList) {
        await box.add(Race.fromJson(json));
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Успешно восстановлено ${jsonList.length} рас')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при восстановлении рас: $e')),
        );
      }
    }
  }

  Future<String> _importFromGoogleDrive(String prefix) async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) throw Exception('Авторизация отменена');

      final client = await _googleSignIn.authenticatedClient();
      if (client == null) throw Exception('Не удалось получить клиент для API');

      _driveApi = drive.DriveApi(client);

      final files = await _driveApi!.files.list(
        q: "name contains '$prefix' and mimeType='application/json'",
        orderBy: 'createdTime desc',
        pageSize: 1,
      );

      if (files.files == null || files.files!.isEmpty) {
        throw Exception('Резервные копии не найдены');
      }

      final file = files.files!.first;
      final response = await _driveApi!.files.get(
        file.id!,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      final bytes = await _readStream(response.stream);
      return utf8.decode(bytes);
    } catch (e) {
      throw Exception('Ошибка при импорте из Google Drive: $e');
    }
  }
}*/