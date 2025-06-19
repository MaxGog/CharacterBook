import 'dart:convert';
import 'dart:io';

import 'package:characterbook/ui/pages/characters/character_management_page.dart';
import 'package:characterbook/ui/pages/races/race_management_page.dart';
import 'package:characterbook/services/file_handler.dart';
import 'package:flutter/material.dart';

import 'models/character_model.dart';
import 'models/race_model.dart';

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
      if (mounted && data is Map) {
        _handleFile(data['path'], data['type']);
      }
    });

    final filePath = await FileHandler.getOpenedFile();
    if (mounted && filePath != null) {
      _handleFile(filePath, filePath.split('.').last);
    }
  }

  Future<void> _handleFile(String path, String type) async {
    if (!mounted) return;

    setState(() => _isHandlingFile = true);

    try {
      final file = File(path);
      if (!await file.exists()) {
        throw Exception("File not found");
      }

      final content = await file.readAsString();
      final json = jsonDecode(content);

      if (type == 'character') {
        final character = Character.fromJson(json);
        _navigateToCharacterEdit(character);
      } else if (type == 'race') {
        final race = Race.fromJson(json);
        _navigateToRaceManagement(race);
      } else {
        throw Exception("Unsupported file type");
      }
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) {
        setState(() => _isHandlingFile = false);
      }
    }
  }

  void _navigateToCharacterEdit(Character character) {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => CharacterEditPage(character: character))
    );
  }

  void _navigateToRaceManagement(Race race) {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => RaceManagementPage(race: race))
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