import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import '../models/character_model.dart';
import '../models/race_model.dart';
import '../models/template_model.dart';
import '../ui/pages/characters/character_management_page.dart';
import '../ui/pages/races/race_management_page.dart';
import '../ui/pages/templates/template_edit_page.dart';
import 'file_handler.dart';

class FileHandlerWrapper extends StatefulWidget {
  final Widget child;

  const FileHandlerWrapper({super.key, required this.child});

  @override
  State<FileHandlerWrapper> createState() => _FileHandlerWrapperState();
}

class _FileHandlerWrapperState extends State<FileHandlerWrapper> {
  bool _isHandlingFile = false;

  @override
  void initState() {
    super.initState();
    _initFileHandling();
  }

  Future<void> _initFileHandling() async {
    FileHandler.onFileOpened.listen((data) {
      if (mounted) {
        _handleFile(
            data['path'],
            data['type'],
            data['originalName'] ?? data['path'].split('/').last()
        );
      }
    });

    final fileData = await FileHandler.getOpenedFile();
    if (mounted && fileData != null) {
      _handleFile(
          fileData['path'],
          fileData['type'],
          fileData['originalName'] ?? fileData['path'].split('/').last
      );
    }
  }

  Future<void> _handleFile(String path, String type, String originalName) async {
    if (!mounted) return;

    setState(() => _isHandlingFile = true);

    try {
      debugPrint('Processing file: $path with type: $type and original name: $originalName');

      final fileExtension = originalName.split('.').last.toLowerCase();
      debugPrint('Actual file extension: $fileExtension');

      if (!['character', 'race', 'chax'].contains(fileExtension)) {
        throw Exception("Unsupported file type: $fileExtension");
      }

      final file = File(path);
      if (!await file.exists()) {
        throw Exception("File not found at path: $path");
      }

      final content = await file.readAsString();
      final json = jsonDecode(content);

      switch (fileExtension) {
        case 'character':
          final character = Character.fromJson(json);
          _navigateToCharacterEdit(character);
          break;
        case 'race':
          final race = Race.fromJson(json);
          _navigateToRaceManagement(race);
          break;
        case 'chax':
          final template = QuestionnaireTemplate.fromJson(json);
          _navigateToTemplateManagement(template);
          break;
      }
    } catch (e, stackTrace) {
      debugPrint('Error handling file: $e');
      debugPrint('Stack trace: $stackTrace');
      _showError(e);
    } finally {
      if (mounted) {
        setState(() => _isHandlingFile = false);
      }
    }
  }

  void _navigateToCharacterEdit(Character character) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CharacterEditPage(character: character),
      ),
    );
  }

  void _navigateToRaceManagement(Race race) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RaceManagementPage(race: race),
      ),
    );
  }

  void _navigateToTemplateManagement(QuestionnaireTemplate template) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TemplateEditPage(template: template),
      ),
    );
  }

  void _showError(dynamic error) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: ${error.toString()}'))
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isHandlingFile
        ? const Scaffold(body: Center(child: CircularProgressIndicator()))
        : widget.child;
  }
}