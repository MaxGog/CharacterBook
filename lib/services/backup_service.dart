import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/data/models/character_model.dart';
import 'package:characterbook/data/models/note_model.dart';
import 'package:characterbook/data/models/race_model.dart';
import 'package:characterbook/data/models/template_model.dart';
import 'package:characterbook/data/models/relationship_model.dart';
import 'package:characterbook/data/repositories/character_repository.dart';
import 'package:characterbook/data/repositories/note_repository.dart';
import 'package:characterbook/data/repositories/race_repository.dart';
import 'package:characterbook/data/repositories/template_repository.dart';
import 'package:characterbook/data/repositories/relationship_repository.dart';
import 'package:characterbook/services/file_picker_service.dart';
import 'package:characterbook/services/notification_service.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_html/html.dart' as html;

class BackupManager {
  final CharacterRepository characterRepo;
  final NoteRepository noteRepo;
  final RaceRepository raceRepo;
  final TemplateRepository templateRepo;
  final RelationshipRepository relationshipRepo;

  BackupManager({
    required this.characterRepo,
    required this.noteRepo,
    required this.raceRepo,
    required this.templateRepo,
    required this.relationshipRepo,
  });

  Future<Map<String, List<dynamic>>> getBackupData() async {
    return {
      'characters': await characterRepo.getAll(),
      'notes': await noteRepo.getAll(),
      'races': await raceRepo.getAll(),
      'templates': await templateRepo.getAll(),
      'relationships': await relationshipRepo.getAll(),
    };
  }

  Future<void> restoreFromBackupData(Map<String, dynamic> data) async {
    await Future.wait([
      characterRepo.clear(),
      noteRepo.clear(),
      raceRepo.clear(),
      templateRepo.clear(),
      relationshipRepo.clear(),
    ]);

    if (data.containsKey('characters')) {
      await _restoreItems<Character>(characterRepo, data['characters']);
    }
    if (data.containsKey('notes')) {
      await _restoreItems<Note>(noteRepo, data['notes']);
    }
    if (data.containsKey('races')) {
      await _restoreItems<Race>(raceRepo, data['races']);
    }
    if (data.containsKey('templates')) {
      await _restoreItems<QuestionnaireTemplate>(
          templateRepo, data['templates']);
    }
    if (data.containsKey('relationships')) {
      await _restoreItems<Relationship>(
          relationshipRepo, data['relationships']);
    }
  }

  Future<void> _restoreItems<T>(dynamic repo, List<dynamic> items) async {
    for (final itemData in items) {
      if (itemData is! Map<String, dynamic>) continue;
      try {
        final item = _createModel(T, itemData);
        if (item != null) {
          await repo.save(item);
        }
      } catch (e) {
        debugPrint('Failed to restore item: $e');
      }
    }
  }

  dynamic _createModel(Type type, Map<String, dynamic> json) {
    if (type == Character) return Character.fromJson(json);
    if (type == Note) return Note.fromJson(json);
    if (type == Race) return Race.fromJson(json);
    if (type == QuestionnaireTemplate)
      return QuestionnaireTemplate.fromJson(json);
    if (type == Relationship) return Relationship.fromJson(json);
    return null;
  }
}

abstract class BackupService {
  Future<void> exportData();
  Future<void> importData();
}

class LocalBackupService implements BackupService {
  final BackupManager backupManager;
  final FilePickerService filePickerService;
  final NotificationService notificationService;

  LocalBackupService({
    required this.backupManager,
    required this.filePickerService,
    required this.notificationService,
  });

  @override
  Future<void> exportData() async {
    try {
      final backupData = await backupManager.getBackupData();
      final hasData = backupData.values.any((list) => list.isNotEmpty);

      if (!hasData) {
        notificationService.showError(S.current.error);
        return;
      }

      final backupJson = jsonEncode(backupData);

      if (kIsWeb) {
        _exportForWeb(backupJson);
      } else {
        await _exportForMobile(backupJson);
      }

      notificationService.showSuccess(S.current.local_backup_success);
    } catch (e) {
      notificationService.showError('${S.current.local_backup_error}: $e');
      debugPrint('Export error: $e');
    }
  }

  void _exportForWeb(String backupJson) {
    final bytes = utf8.encode(backupJson);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..download =
          'characterbook_backup_${DateTime.now().millisecondsSinceEpoch}.characterbook'
      ..style.display = 'none';
    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
    Future<void>.delayed(const Duration(seconds: 1), () {
      html.Url.revokeObjectUrl(url);
    });
  }

  Future<void> _exportForMobile(String backupJson) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName =
        'characterbook_backup_${DateTime.now().millisecondsSinceEpoch}.characterbook';
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(utf8.encode(backupJson));
    await Share.shareXFiles(
      [XFile(file.path)],
      text: S.current.share_backup_file,
      subject: fileName,
    );
  }

  @override
  Future<void> importData() async {
    try {
      final jsonData = await filePickerService.pickRestoreFile();
      if (jsonData == null) {
        throw Exception('Invalid backup file');
      }

      await backupManager.restoreFromBackupData(jsonData);
      notificationService.showSuccess(S.current.local_restore_success);
    } catch (e, stack) {
      notificationService.showError('${S.current.local_restore_error}: $e');
      debugPrint('Restore failed: $e\n$stack');
    }
  }
}

class CloudBackupService implements BackupService {
  final BackupManager backupManager;
  final NotificationService notificationService;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: _scopes);
  drive.DriveApi? _driveApi;
  bool isProcessing = false;

  static const List<String> _scopes = [drive.DriveApi.driveFileScope];
  static const String _backupPrefix = 'characterbook_backup';

  CloudBackupService({
    required this.backupManager,
    required this.notificationService,
  });

  @override
  Future<void> exportData() async {
    try {
      isProcessing = true;
      final backupData = await backupManager.getBackupData();
      final backupJson = jsonEncode(backupData);
      await _exportToGoogleDrive(backupJson);
      notificationService.showSuccess(S.current.cloud_backup_full_success);
    } catch (e) {
      notificationService.showError('${S.current.cloud_backup_error}: $e');
    } finally {
      isProcessing = false;
    }
  }

  @override
  Future<void> importData() async {
    try {
      isProcessing = true;
      final jsonStr = await _importFromGoogleDrive();
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      await backupManager.restoreFromBackupData(data);
      notificationService.showSuccess(
        S.current.cloud_restore_success(0, 0, 0, 0, 0),
      );
    } catch (e) {
      notificationService.showError('${S.current.cloud_restore_error}: $e');
    } finally {
      isProcessing = false;
    }
  }

  Future<void> _exportToGoogleDrive(String jsonStr) async {
    final account = _googleSignIn.currentUser ?? await _googleSignIn.signIn();
    if (account == null) throw Exception(S.current.auth_cancelled);

    final client = await _googleSignIn.authenticatedClient();
    if (client == null) throw Exception(S.current.auth_client_error);

    final driveApi = drive.DriveApi(client);
    final fileName =
        '${_backupPrefix}_${DateTime.now().toIso8601String()}.characterbook';

    await driveApi.files.create(
      drive.File()..name = fileName,
      uploadMedia: drive.Media(
        Stream.value(utf8.encode(jsonStr)),
        utf8.encode(jsonStr).length,
      ),
    );
  }

  Future<String> _importFromGoogleDrive() async {
    final account = await _googleSignIn.signIn();
    if (account == null) throw Exception(S.current.auth_cancelled);

    final client = await _googleSignIn.authenticatedClient();
    if (client == null) throw Exception(S.current.auth_client_error);

    _driveApi ??= drive.DriveApi(client);

    final files = await _driveApi!.files.list(
      q: "name contains '$_backupPrefix' and mimeType='application/characterbook'",
      orderBy: 'createdTime desc',
      pageSize: 1,
    );

    if (files.files == null || files.files!.isEmpty) {
      throw Exception(S.current.cloud_backup_not_found);
    }

    final file = files.files!.first;
    final response = await _driveApi!.files.get(
      file.id!,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;

    final bytes = await _readStream(response.stream);
    return utf8.decode(bytes);
  }

  Future<void> autoExportIfSignedIn() async {
    GoogleSignInAccount? account = _googleSignIn.currentUser;
    account ??= await _googleSignIn.signInSilently();
    if (account != null) {
      await exportData();
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
