import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:hive/hive.dart';
import '../models/character_model.dart';

class CharacterService {
  static const String _boxName = 'characters';

  final Character? character;

  CharacterService.forDatabase() : character = null;

  CharacterService.forExport(this.character);

  Future<Box<Character>> _openBox() async {
    return await Hive.openBox<Character>(_boxName);
  }

  Future<void> saveCharacter(Character character, {int? key}) async {
    final box = await _openBox();
    if (key != null) {
      await box.put(key, character);
    } else {
      await box.add(character);
    }
  }

  Future<List<Character>> getAllCharacters() async {
    final box = await _openBox();
    return box.values.toList();
  }

  Future<void> deleteCharacter(int key) async {
    final box = await _openBox();
    await box.delete(key);
  }

  Future<void> exportToPdf() async {
    if (character == null) throw Exception("Character is not set for export");

    try {
      final fontData = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
      final font = pw.Font.ttf(fontData);
      final fontBold = await rootBundle.load('assets/fonts/NotoSans-Bold.ttf');
      final boldFont = pw.Font.ttf(fontBold);

      final pdf = pw.Document();

      pw.Widget? buildImageFromBytes(Uint8List? bytes) {
        if (bytes == null || bytes.isEmpty) return null;
        return pw.Center(
          child: pw.Image(
            pw.MemoryImage(bytes),
            fit: pw.BoxFit.contain,
            width: 300,
            height: 300,
          ),
        );
      }

      pdf.addPage(
        pw.Page(
          margin: const pw.EdgeInsets.all(20),
          theme: pw.ThemeData.withFont(
            base: font,
            bold: boldFont,
          ),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Text(
                    'Характеристика персонажа',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),

                if (character!.imageBytes != null)
                  pw.Column(
                    children: [
                      buildImageFromBytes(character!.imageBytes)!,
                      pw.SizedBox(height: 20),
                    ],
                  ),

                _buildSectionPdf('Основная информация', [
                  _buildInfoRowPdf('Имя:', character!.name),
                  _buildInfoRowPdf('Возраст:', character!.age.toString()),
                  _buildInfoRowPdf('Пол:', character!.gender),
                  if (character!.race != null)
                    _buildInfoRowPdf('Раса:', character!.race!.name),
                ], context),

                _buildSectionPdf('Биография', [
                  pw.Text(character!.biography),
                ], context),

                _buildSectionPdf('Характер', [
                  pw.Text(character!.personality),
                ], context),

                _buildSectionPdf('Внешность', [
                  pw.Text(character!.appearance),
                ], context),

                if (character!.referenceImageBytes != null)
                  _buildSectionPdf('Референс изображение', [
                    buildImageFromBytes(character!.referenceImageBytes)!,
                  ], context),
              ],
            );
          },
        ),
      );

      pdf.addPage(
        pw.Page(
          margin: const pw.EdgeInsets.all(20),
          theme: pw.ThemeData.withFont(
            base: font,
            bold: boldFont,
          ),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildSectionPdf('Способности', [
                  pw.Text(character!.abilities),
                ], context),

                _buildSectionPdf('Другое', [
                  pw.Text(character!.other),
                ], context),

                if (character!.customFields.isNotEmpty)
                  _buildSectionPdf('Дополнительные поля',
                    character!.customFields.map((field) =>
                        _buildInfoRowPdf('${field.key}:', field.value)
                    ).toList(),
                    context,
                  ),
              ],
            );
          },
        ),
      );

      if (character!.additionalImages.isNotEmpty) {
        pdf.addPage(
          pw.Page(
            margin: const pw.EdgeInsets.all(20),
            theme: pw.ThemeData.withFont(
              base: font,
              bold: boldFont,
            ),
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Header(
                    level: 1,
                    child: pw.Text(
                      'Дополнительные изображения',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  ...character!.additionalImages.map((imageBytes) =>
                      pw.Column(
                        children: [
                          buildImageFromBytes(imageBytes)!,
                          pw.SizedBox(height: 20),
                        ],
                      )
                  ),
                ],
              );
            },
          ),
        );
      }

      final bytes = await pdf.save();
      final fileName = '${character!.name}.pdf'.replaceAll(RegExp(r'[^\w\s-]'), '');
      await _saveAndShareFile(bytes, fileName,
        text: 'Характеристика персонажа ${character!.name}',
        subject: 'PDF с характеристикой персонажа',
      );

    } catch (e) {
      throw Exception('Ошибка экспорта в PDF: ${e.toString()}');
    }
  }

  Future<void> exportToJson() async {
    if (character == null) throw Exception("Character is not set for export");

    try {
      final jsonStr = jsonEncode(character!.toJson());
      final fileName = '${character!.name}_${DateTime.now().millisecondsSinceEpoch}.character';
      await _saveAndShareFile(
        Uint8List.fromList(jsonStr.codeUnits),
        fileName,
        text: 'Персонаж: ${character!.name}',
      );
    } catch (e) {
      throw Exception('Ошибка экспорта в JSON: ${e.toString()}');
    }
  }

  Future<void> _saveAndShareFile(
      Uint8List bytes,
      String fileName, {
        String? text,
        String? subject,
      }) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles(
      [XFile(file.path)],
      text: text,
      subject: subject,
    );
  }

  pw.Widget _buildSectionPdf(String title, List<pw.Widget> children, pw.Context context) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 15),
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Divider(),
        ...children,
      ],
    );
  }

  pw.Widget _buildInfoRowPdf(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(width: 10),
          pw.Expanded(child: pw.Text(value)),
        ],
      ),
    );
  }
}