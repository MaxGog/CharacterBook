import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:universal_html/html.dart' as html;

import '../../../generated/l10n.dart';
import '../../models/template_model.dart';
import '../../services/file_picker_service.dart';
import '../../services/template_service.dart';

class TemplateActions {
  static Future<void> exportTemplate(
      BuildContext context,
      QuestionnaireTemplate template,
      ) async {
    final s = S.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final jsonStr = jsonEncode(template.toJson());

      if (kIsWeb) {
        await _exportTemplateWeb(template.name, jsonStr);
      } else {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/${template.name}.chax');
        await file.writeAsString(jsonStr);

        await _openFile(file.path);
      }

      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(s.template_exported(template.name))),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('${s.export_error}: ${e.toString()}')),
      );
    }
  }

  static Future<void> _exportTemplateWeb(String name, String jsonStr) async {
    final bytes = utf8.encode(jsonStr);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement()
      ..href = url
      ..download = '$name.chax'
      ..style.display = 'none';

    html.document.body?.children.add(anchor);
    anchor.click();

    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }

  static Future<void> importTemplate(
      BuildContext context,
      Function(QuestionnaireTemplate) onImported,
      ) async {
    final s = S.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      if (kIsWeb) {
        final template = await _importTemplateWeb(context);
        if (template != null) onImported(template);
      } else {
        final file = await _pickFileNative(context);
        if (file != null) {
          final jsonStr = await file.readAsString();
          final jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;
          onImported(QuestionnaireTemplate.fromJson(jsonMap));
        }
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('${s.import_error}: ${e.toString()}')),
      );
    }
  }

  static Future<File?> _pickFileNative(BuildContext context) async {
    final s = S.of(context);
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        const channel = MethodChannel('file_picker');
        final filePath = await channel.invokeMethod<String>('pickFile');
        if (filePath == null || filePath.isEmpty) return null;
        return File(filePath);
      } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        final filePath = await _showDesktopFilePicker(context);
        if (filePath == null) return null;
        return File(filePath);
      }
    } on PlatformException catch (e) {
      debugPrint('Failed to pick file: ${e.message}');
      throw Exception('${s.file_pick_error}: ${e.message}');
    } catch (e) {
      debugPrint('Error picking file: $e');
      throw Exception('${s.file_pick_error}: $e');
    }
    return null;
  }

  static Future<String?> _showDesktopFilePicker(BuildContext context) async {
    final s = S.of(context);
    if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) {
      return null;
    }

    final completer = Completer<String?>();
    final filePickerChannel = const MethodChannel('file_picker');

    try {
      final result = await filePickerChannel.invokeMethod<String>('pickFile', {
        'dialogTitle': s.select_template_file,
        'fileExtension': '.chax',
      });
      completer.complete(result);
    } on PlatformException catch (e) {
      debugPrint('Failed to pick file: ${e.message}');
      completer.complete(null);
    }

    return completer.future;
  }

  static Future<QuestionnaireTemplate?> _importTemplateWeb(BuildContext context) async {
    final uploadInput = html.FileUploadInputElement()
      ..accept = '.chax'
      ..multiple = false;

    uploadInput.click();

    await uploadInput.onChange.first;
    final files = uploadInput.files;
    if (files == null || files.isEmpty) return null;

    final file = files[0];
    final reader = html.FileReader();
    reader.readAsText(file);
    await reader.onLoadEnd.first;

    final jsonStr = reader.result as String;
    if (jsonStr.isEmpty) return null;

    final jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;
    return QuestionnaireTemplate.fromJson(jsonMap);
  }

  static Future<void> _openFile(String path) async {
    try {
      const methodChannel = MethodChannel('open_filex');
      await methodChannel.invokeMethod('open_file', {
        'file_path': path,
        'file_type': 'application/json',
      });
    } on PlatformException catch (e) {
      debugPrint('Failed to open file: ${e.message}');
    }
  }
}

Future<Directory> getApplicationDocumentsDirectory() async {
  if (Platform.isAndroid || Platform.isIOS) {
    final path = await MethodChannel('file_picker')
        .invokeMethod<String>('getApplicationDocumentsDirectory');
    return Directory(path!);
  } else {
    return Directory.current;
  }
}