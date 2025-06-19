import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class FileHandler {
  static const MethodChannel _channel = MethodChannel('file_handler');
  static final _fileOpenedController = StreamController<Map<String, dynamic>>.broadcast();

  static Stream<Map<String, dynamic>> get onFileOpened => _fileOpenedController.stream;

  static void initialize() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onFileOpened') {
        _fileOpenedController.add((call.arguments as Map).cast<String, dynamic>());
      }
      return null;
    });
  }

  static Future<Map<String, dynamic>?> getOpenedFile() async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>('getOpenedFile');
      return result?.cast<String, dynamic>();
    } on PlatformException catch (e) {
      debugPrint("Error getting opened file: ${e.message}");
      return null;
    }
  }
}