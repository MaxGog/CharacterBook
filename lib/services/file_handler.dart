import 'dart:async';
import 'package:flutter/services.dart';

class FileHandler {
  static const _channel = MethodChannel('file_handler');
  static final _onFileOpenedController = StreamController<String>.broadcast();

  static Stream<String> get onFileOpened => _onFileOpenedController.stream;

  static void initialize() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onFileOpened') {
        _onFileOpenedController.add(call.arguments as String);
      }
      return null;
    });
  }

  static Future<String?> getOpenedFile() async {
    try {
      return await _channel.invokeMethod('getOpenedFile');
    } on PlatformException catch (e) {
      print("Failed to get opened file: ${e.message}");
      return null;
    }
  }
}