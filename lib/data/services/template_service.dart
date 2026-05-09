import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:characterbook/data/models/character_model.dart';
import 'package:characterbook/data/models/template_model.dart';
import 'package:characterbook/data/repositories/template_repository.dart';
import 'package:characterbook/services/file_picker_service.dart';
import 'package:characterbook/services/file_share_service.dart';
import 'package:characterbook/services/word_export_manager.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class TemplateService {
  final TemplateRepository _repository;

  TemplateService(this._repository);

  Future<void> initializeDefaultTemplates() =>
      _repository.initializeDefaultTemplates();

  Future<void> saveTemplate(QuestionnaireTemplate template) =>
      _repository.save(template);

  Future<List<QuestionnaireTemplate>> getAllTemplates() => _repository.getAll();

  Future<void> deleteTemplate(String name) => _repository.delete(name);

  Future<File> exportTemplate(QuestionnaireTemplate template) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${template.name}.chax');
    await file.writeAsString(jsonEncode(template.toJson()));
    return file;
  }

  Future<QuestionnaireTemplate> importTemplate(File file) async {
    final content = await file.readAsString();
    final json = jsonDecode(content);
    return QuestionnaireTemplate.fromJson(json);
  }

  QuestionnaireTemplate createTemplateFromCharacter(
    String name,
    Character character,
    List<String> includedStandardFields,
  ) {
    return QuestionnaireTemplate(
      name: name,
      standardFields: includedStandardFields,
      customFields: character.customFields.map((f) => f.copyWith()).toList(),
    );
  }

  Future<QuestionnaireTemplate?> pickAndImportTemplate() async {
    try {
      return await FilePickerService().importTemplate();
    } catch (e) {
      throw Exception('Ошибка импорта шаблона: ${e.toString()}');
    }
  }

  Future<void> shareTemplate(QuestionnaireTemplate template) async {
    try {
      final String templateJson = jsonEncode(template.toJson());
      final Uint8List bytes = Uint8List.fromList(utf8.encode(templateJson));
      await FileShareService.shareFile(
        bytes,
        '${template.name}.chax',
        text: 'Шаблон персонажа: ${template.name}',
        subject: 'Шаблон персонажа',
      );
    } catch (e) {
      throw Exception('Ошибка при шаринге шаблона: ${e.toString()}');
    }
  }

  Future<void> exportToWord(BuildContext context, QuestionnaireTemplate template) async {
    await WordExportManager.exportTemplateWithDialog(context, template);
  }
}
