import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:universal_html/html.dart' as html;
import '../models/character_model.dart';

class FilePickerService {
  Future<Character?> importCharacter() async {
    try {
      String? jsonStr;

      if (kIsWeb) {
        final uploadInput = html.FileUploadInputElement();
        uploadInput.accept = '.character';
        uploadInput.click();

        await uploadInput.onChange.first;
        final files = uploadInput.files;
        if (files == null || files.isEmpty) return null;

        final file = files[0];
        final reader = html.FileReader();
        reader.readAsText(file);
        await reader.onLoadEnd.first;
        jsonStr = reader.result as String;
      } else {
        final file = await _pickFileNative();
        if (file == null) return null;
        jsonStr = await file.readAsString();
      }

      if (jsonStr.isEmpty) return null;

      final jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;
      return Character.fromJson(jsonMap);
    } catch (e) {
      throw Exception('Ошибка импорта: ${e.toString()}');
    }
  }

  Future<File?> _pickFileNative() async {
    if (kIsWeb) return null;

    try {
      if (Platform.isAndroid || Platform.isIOS) {
        const channel = MethodChannel('file_picker');
        final filePath = await channel.invokeMethod<String>('pickFile');
        if (filePath == null || filePath.isEmpty) return null;
        return File(filePath);
      } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        final filePath = await _showDesktopFilePicker();
        if (filePath == null) return null;
        return File(filePath);
      }
    } on PlatformException catch (e) {
      debugPrint('Failed to pick file: ${e.message}');
      throw Exception('Ошибка выбора файла: ${e.message}');
    } catch (e) {
      debugPrint('Error picking file: $e');
      throw Exception('Ошибка выбора файла: $e');
    }
    return null;
  }

  Future<String?> _showDesktopFilePicker() async {
    if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) {
      return null;
    }

    final completer = Completer<String?>();
    final filePickerChannel = const MethodChannel('file_picker');

    try {
      final result = await filePickerChannel.invokeMethod<String>('pickFile', {
        'dialogTitle': 'Выберите файл персонажа',
        'fileExtension': '.character',
      });
      completer.complete(result);
    } on PlatformException catch (e) {
      debugPrint('Failed to pick file: ${e.message}');
      completer.complete(null);
    }

    return completer.future;
  }
}