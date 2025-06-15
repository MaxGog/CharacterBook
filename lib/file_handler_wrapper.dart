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
    FileHandler.onFileOpened.listen(_handleOpenedFile as void Function(dynamic event)?);

    final filePath = await FileHandler.getOpenedFile();
    if (filePath != null && mounted) {
      setState(() => _isHandlingFile = true);
      _handleOpenedFile(filePath);
    }
  }

  void _handleOpenedFile(String filePath) {
    final file = File(filePath);
    final extension = file.path.split('.').last.toLowerCase();

    if (extension == 'character') {
      _handleCharacterFile(file);
    } else if (extension == 'race') {
      _handleRaceFile(file);
    }
  }

  Future<void> _handleCharacterFile(File file) async {
    try {
      final content = await file.readAsString();
      final json = jsonDecode(content);
      final character = Character.fromJson(json);

      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => CharacterEditPage(character: character),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки персонажа: $e')));
    } finally {
      if (mounted) {
        setState(() => _isHandlingFile = false);
      }
    }
  }

  Future<void> _handleRaceFile(File file) async {
    try {
      final content = await file.readAsString();
      final json = jsonDecode(content);
      final race = Race.fromJson(json);

      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => RaceManagementPage(race: race),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки расы: $e')));
    } finally {
      if (mounted) {
        setState(() => _isHandlingFile = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isHandlingFile
        ? const Scaffold(body: Center(child: CircularProgressIndicator()))
        : widget.child;
  }
}