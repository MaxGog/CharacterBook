import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:universal_html/html.dart' as html;
import '../models/character_model.dart';
import '../models/race_model.dart';
import '../models/template_model.dart';

class FilePickerService {
  Future<File?> _pickFileNative({String? fileExtension}) async {
    if (kIsWeb) return null;

    try {
      if (Platform.isAndroid || Platform.isIOS) {
        const channel = MethodChannel('file_picker');
        final filePath = await channel.invokeMethod<String>('pickFile', {
          'fileExtension': fileExtension,
        });
        if (filePath == null || filePath.isEmpty) return null;
        return File(filePath);
      } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        final filePath = await _showDesktopFilePicker(fileExtension: fileExtension);
        if (filePath == null) return null;
        return File(filePath);
      }
    } on PlatformException catch (e) {
      throw Exception('Ошибка выбора файла: ${e.message}');
    } catch (e) {
      throw Exception('Ошибка выбора файла: $e');
    }
    return null;
  }

  Future<String?> _showDesktopFilePicker({String? fileExtension}) async {
    if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) {
      return null;
    }

    final filePickerChannel = const MethodChannel('file_picker');
    try {
      return await filePickerChannel.invokeMethod<String>('pickFile', {
        'dialogTitle': 'Выберите файл',
        'fileExtension': fileExtension,
      });
    } on PlatformException catch (e) {
      return null;
    }
  }

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
        final file = await _pickFileNative(fileExtension: '.character');
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

  Future<Race?> importRace() async {
    try {
      String? jsonStr;

      if (kIsWeb) {
        final uploadInput = html.FileUploadInputElement();
        uploadInput.accept = '.race';
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
        final file = await _pickFileNative(fileExtension: '.race');
        if (file == null) return null;
        jsonStr = await file.readAsString();
      }

      if (jsonStr.isEmpty) return null;

      final jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;
      return Race.fromJson(jsonMap);
    } catch (e) {
      throw Exception('Ошибка импорта расы: ${e.toString()}');
    }
  }

  Future<QuestionnaireTemplate?> importTemplate() async {
    try {
      String? jsonStr;

      if (kIsWeb) {
        final uploadInput = html.FileUploadInputElement();
        uploadInput.accept = '.chax';
        uploadInput.click();

        await uploadInput.onChange.first;
        final files = uploadInput.files;
        if (files == null || files.isEmpty) return null;

        final file = files[0];
        final reader = html.FileReader();
        reader.readAsText(file);
        await reader.onLoadEnd.first;
        jsonStr = reader.result as String?;
      } else {
        final file = await _pickFileNative(fileExtension: '.chax');
        if (file == null) return null;
        jsonStr = await file.readAsString();
      }

      if (jsonStr == null || jsonStr.isEmpty) {
        debugPrint('Empty or invalid JSON content');
        return null;
      }

      debugPrint('JSON content start: ${jsonStr.substring(0, min(100, jsonStr.length))}...');

      final jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;
      return QuestionnaireTemplate.fromJson(jsonMap);
    } catch (e, stackTrace) {
      debugPrint('Error importing template: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Ошибка импорта шаблона: ${e.toString()}');
    }
  }
}