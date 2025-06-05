import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:hive/hive.dart';
import '../models/character_model.dart';
import '../models/note_model.dart';

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

      final backupData = {
        'characters': characters,
        'notes': notes,
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

      final charactersBox = Hive.box<Character>('characters');
      await charactersBox.clear();
      final List<dynamic> charactersJson = data['characters'];
      for (final json in charactersJson) {
        await charactersBox.add(Character.fromJson(json));
      }

      final notesBox = Hive.box<Note>('notes');
      await notesBox.clear();
      final List<dynamic> notesJson = data['notes'];
      for (final json in notesJson) {
        await notesBox.add(Note.fromJson(json));
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Успешно восстановлено ${charactersJson.length} персонажей и ${notesJson.length} постов',
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