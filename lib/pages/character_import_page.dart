import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;
import 'package:share_plus/share_plus.dart';
import '../models/character_model.dart';

class CharacterImportPage extends StatefulWidget {
  const CharacterImportPage({super.key});

  @override
  State<CharacterImportPage> createState() => _CharacterImportPageState();
}

class _CharacterImportPageState extends State<CharacterImportPage> {
  bool _isImporting = false;
  String? _errorMessage;

  Future<void> _importCharacter(BuildContext context) async {
    try {
      setState(() {
        _isImporting = true;
        _errorMessage = null;
      });

      String? jsonStr;
      String? fileName;

      if (kIsWeb) {
        final uploadInput = html.FileUploadInputElement();
        uploadInput.accept = '.character';
        uploadInput.click();

        await uploadInput.onChange.first;
        final files = uploadInput.files;
        if (files == null || files.isEmpty) return;

        final file = files[0];
        fileName = file.name;
        final reader = html.FileReader();
        reader.readAsText(file);
        await reader.onLoadEnd.first;
        jsonStr = reader.result as String;
      } else {
        final filePath = await _pickFile(context);
        if (filePath == null) return;

        final file = File(filePath);
        fileName = file.path.split('/').last;
        jsonStr = await file.readAsString();
      }

      if (jsonStr == null || jsonStr.isEmpty) return;

      final jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;
      final character = Character.fromJson(jsonMap);
      final box = Hive.box<Character>('characters');
      await box.add(character);

      await _shareFile(context, jsonStr, fileName ?? 'character_${DateTime.now().millisecondsSinceEpoch}.character');

      if (mounted) {
        Navigator.pop(context, character);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка импорта: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isImporting = false;
      });
    }
  }

  Future<void> _shareFile(BuildContext context, String content, String fileName) async {
    try {
      if (kIsWeb) {
        final bytes = utf8.encode(content);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);

        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();

        html.Url.revokeObjectUrl(url);
      } else {
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/$fileName');
        await tempFile.writeAsString(content);

        await Share.shareXFiles([XFile(tempFile.path)], text: 'Поделиться персонажем');

        await tempFile.delete();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при попытке поделиться: ${e.toString()}')),
        );
      }
    }
  }

  Future<String?> _pickFile(BuildContext context) async {
    if (kIsWeb) return null;

    if (Platform.isAndroid || Platform.isIOS) {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = await _showFileSelectionDialog(context, initialPath: directory.path);
      return filePath;
    } else {
      return await _showFileSelectionDialog(context);
    }
  }

  Future<String?> _showFileSelectionDialog(BuildContext context, {String? initialPath}) async {
    if (kIsWeb) return null;

    final controller = TextEditingController(text: initialPath);
    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Выберите файл'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Путь к файлу',
            hintText: 'Введите путь к файлу .character',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text('Выбрать'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Импорт персонажа'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_add,
                size: 64,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Импорт персонажа из файла',
                style: textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Выберите файл с расширением .character',
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _errorMessage!,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              FilledButton(
                onPressed: _isImporting ? null : () => _importCharacter(context),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isImporting
                    ? const CircularProgressIndicator()
                    : const Text('Выбрать файл'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}