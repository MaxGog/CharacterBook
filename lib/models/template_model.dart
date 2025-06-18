import 'package:hive/hive.dart';
import 'character_model.dart';
import 'custom_field_model.dart';
import 'dart:convert';

part 'template_model.g.dart';

@HiveType(typeId: 4)
class QuestionnaireTemplate extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  List<String> standardFields;

  @HiveField(2)
  List<CustomField> customFields;

  QuestionnaireTemplate({
    required this.name,
    List<String>? standardFields,
    List<CustomField>? customFields,
  })  : standardFields = standardFields ?? [],
        customFields = customFields ?? [];

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'standardFields': standardFields,
      'customFields': customFields.map((f) => f.toJson()).toList(),
    };
  }

  factory QuestionnaireTemplate.fromJson(Map<String, dynamic> json) {
    try {
      if (json['name'] == null) {
        throw const FormatException('Missing required field: name');
      }

      return QuestionnaireTemplate(
        name: json['name'] as String,
        standardFields: _parseStandardFields(json['standardFields']),
        customFields: _parseCustomFields(json['customFields']),
      );
    } catch (e) {
      throw FormatException('Failed to parse QuestionnaireTemplate: $e');
    }
  }

  static List<String> _parseStandardFields(dynamic fields) {
    if (fields == null) return [];
    if (fields is! List) {
      throw FormatException('standardFields should be a List');
    }
    return List<String>.from(fields);
  }

  static List<CustomField> _parseCustomFields(dynamic fields) {
    if (fields == null) return [];
    if (fields is! List) {
      throw FormatException('customFields should be a List');
    }

    return fields.map((e) {
      try {
        return CustomField.fromJson(e as Map<String, dynamic>);
      } catch (e) {
        throw FormatException('Failed to parse CustomField: $e');
      }
    }).toList();
  }

  factory QuestionnaireTemplate.fromJsonString(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      return QuestionnaireTemplate.fromJson(decoded);
    } on FormatException catch (e) {
      throw FormatException('Invalid JSON format: $e');
    } catch (e) {
      throw FormatException('Failed to decode JSON: $e');
    }
  }

  Character applyToCharacter(Character character) {
    return character.copyWith(
      name: character.name.isEmpty ? 'Новый персонаж' : character.name,
      customFields: customFields.map((f) => f.copyWith()).toList(),
    );
  }

  Character createCharacterFromTemplate() {
    return applyToCharacter(Character.empty());
  }

  bool containsField(String fieldName) {
    return standardFields.contains(fieldName) ||
        customFields.any((field) => field.key == fieldName);
  }
}