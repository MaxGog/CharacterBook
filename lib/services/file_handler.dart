import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:characterbook/models/character_model.dart';
import 'package:characterbook/models/race_model.dart';

class FileHandler {
  static const _channel = MethodChannel('file_handler');
  static final _onFileOpenedController = StreamController<dynamic>.broadcast();

  static Stream<dynamic> get onFileOpened => _onFileOpenedController.stream;

  static void initialize() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onFileOpened') {
        final filePath = call.arguments as String;
        try {
          final file = File(filePath);
          final content = await file.readAsString();
          final data = jsonDecode(content);

          if (filePath.endsWith('.character')) {
            final character = Character.fromJson(data);
            _onFileOpenedController.add(character);
          } else if (filePath.endsWith('.race')) {
            final race = Race.fromJson(data);
            _onFileOpenedController.add(race);
          }
        } catch (e) {
          _onFileOpenedController.addError(e);
        }
      }
      return null;
    });
  }

  static Future<dynamic> getOpenedFile() async {
    try {
      final filePath = await _channel.invokeMethod('getOpenedFile');
      if (filePath == null) return null;

      final file = File(filePath);
      final content = await file.readAsString();
      final data = jsonDecode(content);

      if (filePath.endsWith('.character')) {
        return Character.fromJson(data);
      } else if (filePath.endsWith('.race')) {
        return Race.fromJson(data);
      }
      return null;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("Failed to get opened file: ${e.message}");
      }
      return null;
    }
  }

  static Future<void> saveCharacterToFile(Character character, String filePath) async {
    final json = character.toJson();
    final content = jsonEncode(json);
    await File(filePath).writeAsString(content);
  }

  static Future<void> saveRaceToFile(Race race, String filePath) async {
    final json = race.toJson();
    final content = jsonEncode(json);
    await File(filePath).writeAsString(content);
  }
}