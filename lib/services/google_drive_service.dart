import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:hive/hive.dart';
import '../generated/l10n.dart';
import '../models/character_model.dart';
import '../models/note_model.dart';
import '../models/race_model.dart';
import '../models/template_model.dart';

class CloudBackupService {
  static const List<String> _scopes = [drive.DriveApi.driveFileScope];
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: _scopes);
  drive.DriveApi? _driveApi;

  Future<void> exportAllToCloud(BuildContext context) async {
    try {
      final charactersBox = Hive.box<Character>('characters');
      final characters = charactersBox.values.toList();

      final notesBox = Hive.box<Note>('notes');
      final notes = notesBox.values.toList();

      final racesBox = Hive.box<Race>('races');
      final races = racesBox.values.toList();

      final templatesBox = Hive.box<QuestionnaireTemplate>('templates');
      final templates = templatesBox.values.toList();

      final backupData = {
        'characters': characters,
        'notes': notes,
        'races': races,
        'templates': templates,
      };
      final backupJson = jsonEncode(backupData);

      await _exportToGoogleDrive(context, backupJson, 'characterbook_backup');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).cloud_backup_full_success)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.of(context).cloud_backup_error}: $e')),
        );
      }
    }
  }

  Future<void> exportCharactersToCloud(BuildContext context) async {
    try {
      final box = Hive.box<Character>('characters');
      final characters = box.values.toList();
      final jsonStr = jsonEncode(characters.map((c) => c.toJson()).toList());

      await _exportToGoogleDrive(context, jsonStr, 'characters_backup');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).cloud_backup_characters_success)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.of(context).cloud_backup_characters_error}: $e')),
        );
      }
    }
  }

  Future<void> exportNotesToCloud(BuildContext context) async {
    try {
      final box = Hive.box<Note>('notes');
      final notes = box.values.toList();
      final jsonStr = jsonEncode(notes.map((n) => n.toJson()).toList());

      await _exportToGoogleDrive(context, jsonStr, 'notes_backup');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).operationCompleted)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.of(context).error}: $e')),
        );
      }
    }
  }

  Future<void> exportRacesToCloud(BuildContext context) async {
    try {
      final box = Hive.box<Race>('races');
      final races = box.values.toList();
      final jsonStr = jsonEncode(races.map((r) => r.toJson()).toList());

      await _exportToGoogleDrive(context, jsonStr, 'races_backup');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).operationCompleted)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.of(context).error}: $e')),
        );
      }
    }
  }

  Future<void> exportTemplatesToCloud(BuildContext context) async {
    try {
      final box = Hive.box<QuestionnaireTemplate>('templates');
      final templates = box.values.toList();
      final jsonStr = jsonEncode(templates.map((t) => t.toJson()).toList());

      await _exportToGoogleDrive(context, jsonStr, 'templates_backup');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).operationCompleted)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.of(context).error}: $e')),
        );
      }
    }
  }

  Future<void> _exportToGoogleDrive(
      BuildContext context,
      String jsonStr,
      String prefix,
      ) async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) throw Exception(S.of(context).auth_cancelled);

      final client = await _googleSignIn.authenticatedClient();
      if (client == null) throw Exception(S.of(context).auth_client_error);

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
      throw Exception('${S.of(context).cloud_export_error}: $e');
    }
  }

  Future<void> importAllFromCloud(BuildContext context) async {
    try {
      final jsonStr = await _importFromGoogleDrive(context, 'characterbook_backup');
      final Map<String, dynamic> data = jsonDecode(jsonStr);

      final racesBox = Hive.box<Race>('races');
      await racesBox.clear();
      final List<dynamic> racesJson = data['races'] ?? [];
      for (final json in racesJson) {
        await racesBox.add(Race.fromJson(json));
      }

      final templatesBox = Hive.box<QuestionnaireTemplate>('templates');
      await templatesBox.clear();
      final List<dynamic> templatesJson = data['templates'] ?? [];
      for (final json in templatesJson) {
        await templatesBox.add(QuestionnaireTemplate.fromJson(json));
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
              S.of(context).cloud_restore_success
                  (charactersJson.length.toString(),
                  notesJson.length.toString(),
                  racesJson.length.toString(),
                  templatesJson.length.toString())
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.of(context).cloud_restore_error}: $e')),
        );
      }
    }
  }

  Future<void> importCharactersFromCloud(BuildContext context) async {
    try {
      final jsonStr = await _importFromGoogleDrive(context, 'characters_backup');

      final box = Hive.box<Character>('characters');
      await box.clear();

      final List<dynamic> jsonList = jsonDecode(jsonStr);
      for (final json in jsonList) {
        await box.add(Character.fromJson(json));
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).character_imported(jsonList.length.toString()))),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.of(context).cloud_restore_error}: $e')),
        );
      }
    }
  }

  Future<void> importNotesFromCloud(BuildContext context) async {
    try {
      final jsonStr = await _importFromGoogleDrive(context, 'notes_backup');

      final box = Hive.box<Note>('notes');
      await box.clear();

      final List<dynamic> jsonList = jsonDecode(jsonStr);
      for (final json in jsonList) {
        await box.add(Note.fromJson(json));
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).operationCompleted)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.of(context).error}: $e')),
        );
      }
    }
  }

  Future<void> importRacesFromCloud(BuildContext context) async {
    try {
      final jsonStr = await _importFromGoogleDrive(context, 'races_backup');

      final box = Hive.box<Race>('races');
      await box.clear();

      final List<dynamic> jsonList = jsonDecode(jsonStr);
      for (final json in jsonList) {
        await box.add(Race.fromJson(json));
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).race_imported(jsonList.length.toString()))),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.of(context).error}: $e')),
        );
      }
    }
  }

  Future<void> importTemplatesFromCloud(BuildContext context) async {
    try {
      final jsonStr = await _importFromGoogleDrive(context, 'templates_backup');

      final box = Hive.box<QuestionnaireTemplate>('templates');
      await box.clear();

      final List<dynamic> jsonList = jsonDecode(jsonStr);
      for (final json in jsonList) {
        await box.add(QuestionnaireTemplate.fromJson(json));
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).template_imported(jsonList.length.toString()))),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.of(context).error}: $e')),
        );
      }
    }
  }

  Future<String> _importFromGoogleDrive(
      BuildContext context,
      String prefix,
      ) async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) throw Exception(S.of(context).auth_cancelled);

      final client = await _googleSignIn.authenticatedClient();
      if (client == null) throw Exception(S.of(context).auth_client_error);

      _driveApi = drive.DriveApi(client);

      final files = await _driveApi!.files.list(
        q: "name contains '$prefix' and mimeType='application/json'",
        orderBy: 'createdTime desc',
        pageSize: 1,
      );

      if (files.files == null || files.files!.isEmpty) {
        throw Exception(S.of(context).cloud_backup_not_found);
      }

      final file = files.files!.first;
      final response = await _driveApi!.files.get(
        file.id!,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      final bytes = await _readStream(response.stream);
      return utf8.decode(bytes);
    } catch (e) {
      throw Exception('${S.of(context).cloud_import_error}: $e');
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