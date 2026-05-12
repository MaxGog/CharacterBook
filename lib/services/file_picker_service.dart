import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:characterbook/data/models/character_model.dart';
import 'package:characterbook/data/models/note_model.dart';
import 'package:characterbook/data/models/race_model.dart';
import 'package:characterbook/data/models/template_model.dart';
import 'package:characterbook/ui/widgets/dialogs/error_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:universal_html/html.dart' as html;

class FilePickerService {
  static const _channel = MethodChannel('file_picker');

  static void _showErrorDialog(BuildContext? context, String message) {
    if (context == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        showErrorDialog(
          context: context,
          title: 'Ошибка файла',
          message: message,
        );
      }
    });
  }

  Future<Map<String, dynamic>?> pickRestoreFile({BuildContext? context}) async {
    try {
      if (kIsWeb) {
        return await _pickRestoreFileWeb();
      } else {
        return await _pickRestoreFileNative();
      }
    } catch (e) {
      debugPrint('Restore file picker error: $e');
      final errorMessage =
          'Не удалось выбрать файл для восстановления: ${e.toString()}';
      if (context != null) {
        _showErrorDialog(context, errorMessage);
      }
      return null;
    }
  }

  Future<Map<String, dynamic>?> _pickRestoreFileWeb() async {
    try {
      final uploadInput = html.FileUploadInputElement();
      uploadInput.accept = '.json,.characterbook';
      uploadInput.click();

      final completer = Completer<html.FileUploadInputElement?>();
      uploadInput.onChange.listen((event) {
        completer.complete(uploadInput);
      });

      await completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () =>
            throw TimeoutException('Выбор файла занял слишком много времени'),
      );

      final files = uploadInput.files;
      if (files == null || files.isEmpty) return null;

      final file = files[0];
      final reader = html.FileReader();

      final readCompleter = Completer<void>();
      reader.onLoadEnd.listen((event) {
        readCompleter.complete();
      });

      reader.readAsText(file);
      await readCompleter.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () =>
            throw TimeoutException('Чтение файла заняло слишком много времени'),
      );

      final jsonStr = reader.result as String;
      if (jsonStr.isEmpty) return null;

      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Ошибка выбора файла в веб-версии: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>?> _pickRestoreFileNative() async {
    try {
      final filePath =
          await _pickFileNative(fileExtension: '.json,.characterbook').timeout(
        const Duration(seconds: 30),
        onTimeout: () =>
            throw TimeoutException('Выбор файла занял слишком много времени'),
      );

      if (filePath == null || filePath.isEmpty) {
        debugPrint('No file selected or empty file path');
        return null;
      }

      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Файл не существует: $filePath');
      }

      final jsonStr = await file.readAsString().timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException(
                'Чтение файла заняло слишком много времени'),
          );

      if (jsonStr.isEmpty) {
        throw Exception('Файл пуст');
      }

      try {
        final decoded = jsonDecode(jsonStr);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        } else {
          throw Exception('Неверный формат файла: ожидался JSON объект');
        }
      } catch (e) {
        throw Exception('Ошибка формата JSON: ${e.toString()}');
      }
    } catch (e) {
      throw Exception('Ошибка выбора файла в нативной версии: ${e.toString()}');
    }
  }

  Future<String?> _pickFileNative({String? fileExtension}) async {
    try {
      debugPrint('Requesting file pick with extension: $fileExtension');

      final result = await _channel.invokeMethod<String>('pickFile', {
        'fileExtension': fileExtension,
      }).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException(
            'Выбор файла через нативный канал занял слишком много времени'),
      );

      debugPrint('File picker result: $result');
      return result;
    } catch (e) {
      throw Exception('Ошибка нативного выбора файла: ${e.toString()}');
    }
  }

  Future<Character?> importCharacter({BuildContext? context}) async {
    try {
      String? jsonStr;

      if (kIsWeb) {
        jsonStr = await _importFileWeb('.character', 'character');
      } else {
        jsonStr = await _importFileNative('.character');
      }

      if (jsonStr == null || jsonStr.isEmpty) return null;

      final jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;
      return Character.fromJson(jsonMap);
    } catch (e) {
      final errorMessage =
          'Не удалось импортировать персонажа: ${e.toString()}';
      if (context != null) {
        _showErrorDialog(context, errorMessage);
      }
      rethrow;
    }
  }

  Future<Race?> importRace({BuildContext? context}) async {
    try {
      String? jsonStr;

      if (kIsWeb) {
        jsonStr = await _importFileWeb('.race', 'race');
      } else {
        jsonStr = await _importFileNative('.race');
      }

      if (jsonStr == null || jsonStr.isEmpty) return null;

      final jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;
      return Race.fromJson(jsonMap);
    } catch (e) {
      final errorMessage = 'Не удалось импортировать расу: ${e.toString()}';
      if (context != null) {
        _showErrorDialog(context, errorMessage);
      }
      rethrow;
    }
  }

  Future<QuestionnaireTemplate?> importTemplate({BuildContext? context}) async {
    try {
      String? jsonStr;

      if (kIsWeb) {
        jsonStr = await _importFileWeb('.chax', 'template');
      } else {
        jsonStr = await _importFileNative('.chax');
      }

      if (jsonStr == null || jsonStr.isEmpty) {
        return null;
      }

      final jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;
      return QuestionnaireTemplate.fromJson(jsonMap);
    } catch (e) {
      final errorMessage = 'Не удалось импортировать шаблон: ${e.toString()}';
      if (context != null) {
        _showErrorDialog(context, errorMessage);
      }
      rethrow;
    }
  }

  Future<String?> _importFileWeb(String accept, String fileType) async {
    try {
      final uploadInput = html.FileUploadInputElement();
      uploadInput.accept = accept;
      uploadInput.click();

      final completer = Completer<html.FileUploadInputElement?>();
      uploadInput.onChange.listen((event) {
        completer.complete(uploadInput);
      });

      await completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException(
            'Выбор файла $fileType занял слишком много времени'),
      );

      final files = uploadInput.files;
      if (files == null || files.isEmpty) return null;

      final file = files[0];
      final reader = html.FileReader();

      final readCompleter = Completer<void>();
      reader.onLoadEnd.listen((event) {
        readCompleter.complete();
      });

      reader.readAsText(file);
      await readCompleter.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException(
            'Чтение файла $fileType заняло слишком много времени'),
      );

      return reader.result as String?;
    } catch (e) {
      throw Exception('Ошибка импорта $fileType в веб-версии: ${e.toString()}');
    }
  }

  Future<String?> _importFileNative(String fileExtension) async {
    try {
      final filePath =
          await _pickFileNative(fileExtension: fileExtension).timeout(
        const Duration(seconds: 30),
        onTimeout: () =>
            throw TimeoutException('Выбор файла занял слишком много времени'),
      );

      if (filePath == null) return null;

      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Файл не существует: $filePath');
      }

      return await file.readAsString().timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException(
                'Чтение файла заняло слишком много времени'),
          );
    } catch (e) {
      throw Exception(
          'Ошибка импорта файла в нативной версии: ${e.toString()}');
    }
  }

  Future<Note?> importNote({BuildContext? context}) async {
    try {
      String? jsonStr;

      if (kIsWeb) {
        jsonStr = await _importFileWeb('.note', 'note');
      } else {
        jsonStr = await _importFileNative('.note');
      }

      if (jsonStr == null || jsonStr.isEmpty) return null;

      final jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;
      return Note.fromJson(jsonMap);
    } catch (e) {
      final errorMessage = 'Не удалось импортировать заметку: ${e.toString()}';
      if (context != null) {
        _showErrorDialog(context, errorMessage);
      }
      rethrow;
    }
  }
}
