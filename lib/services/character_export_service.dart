import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/character_model.dart';

class CharacterExportService {
  Future<void> exportToPdf(Character character) async {
    final pdf = pw.Document();

    final bytes = await pdf.save();
    await _saveAndShareFile(bytes, '${character.name}_character.pdf');
  }

  Future<void> exportToJson(Character character) async {
    final jsonStr = jsonEncode(character.toJson());
    await _saveAndShareFile(
        Uint8List.fromList(jsonStr.codeUnits),
        '${character.name}_${DateTime.now().millisecondsSinceEpoch}.character'
    );
  }

  Future<void> _saveAndShareFile(Uint8List bytes, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(file.path)]);
  }
}