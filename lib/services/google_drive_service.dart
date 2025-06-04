import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:hive/hive.dart';
import '../models/character_model.dart';

class CloudBackupService {
  static const List<String> _scopes = [drive.DriveApi.driveFileScope];
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: _scopes);
  drive.DriveApi? _driveApi;

  Future<void> exportToCloud(BuildContext context) async {
    try {
      final box = Hive.box<Character>('characters');
      final characters = box.values.toList();
      final jsonStr = jsonEncode(characters.map((c) => c.toJson()).toList());

      await _exportToGoogleDrive(jsonStr);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Резервная копия успешно создана в Google Drive')),
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

  Future<void> _exportToGoogleDrive(String jsonStr) async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) throw Exception('Авторизация отменена');

      final client = await _googleSignIn.authenticatedClient();
      if (client == null) throw Exception('Не удалось получить клиент для API');

      _driveApi = drive.DriveApi(client);

      final fileMetadata = drive.File()
        ..name = 'characters_backup_${DateTime.now().toIso8601String()}.json'
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

  Future<void> importFromCloud(BuildContext context) async {
    try {
      final jsonStr = await _importFromGoogleDrive();

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
          SnackBar(content: Text('Ошибка при восстановлении данных: $e')),
        );
      }
    }
  }

  Future<String> _importFromGoogleDrive() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) throw Exception('Авторизация отменена');

      final client = await _googleSignIn.authenticatedClient();
      if (client == null) throw Exception('Не удалось получить клиент для API');

      _driveApi = drive.DriveApi(client);

      final files = await _driveApi!.files.list(
        q: "name contains 'characters_backup' and mimeType='application/json'",
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