import 'package:hive/hive.dart';
import 'character_model.dart';
import 'custom_field_model.dart';

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
    return QuestionnaireTemplate(
      name: json['name'],
      standardFields: List<String>.from(json['standardFields'] ?? []),
      customFields: (json['customFields'] as List?)
          ?.map((e) => CustomField.fromJson(e))
          .toList() ?? [],
    );
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
}