import 'dart:typed_data';

import 'package:hive/hive.dart';

import 'custom_field_model.dart';

part 'character_model.g.dart';

@HiveType(typeId: 0)
class Character extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int age;

  @HiveField(2)
  String gender;

  @HiveField(3)
  String biography;

  @HiveField(4)
  String personality;

  @HiveField(5)
  String appearance;

  @HiveField(6)
  Uint8List? imageBytes;

  @HiveField(7)
  String abilities;

  @HiveField(8)
  String other;

  @HiveField(9)
  Uint8List? referenceImageBytes;

  @HiveField(10)
  List<CustomField> customFields;

  @HiveField(11)
  List<Uint8List> additionalImages = [];

  Character({
    this.name = '',
    this.age = 0,
    this.gender = '',
    this.biography = '',
    this.personality = '',
    this.appearance = '',
    this.abilities = '',
    this.other = '',
    this.imageBytes,
    this.referenceImageBytes,
    List<CustomField>? customFields,
    List<Uint8List>? additionalImages,
  }) :
      customFields = customFields ?? [],
      additionalImages = additionalImages ?? [];


  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'gender': gender,
      'biography': biography,
      'personality': personality,
      'appearance': appearance,
      'abilities': abilities,
      'other': other,
      'imageBytes': imageBytes?.toList(),
      'referenceImageBytes': referenceImageBytes?.toList(),
      'customFields': customFields.map((f) => {'key': f.key, 'value': f.value}).toList(),
      'additionalImages': additionalImages.map((img) => img.toList()).toList(),
    };
  }

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
      gender: json['gender'] ?? '',
      biography: json['biography'] ?? '',
      personality: json['personality'] ?? '',
      appearance: json['appearance'] ?? '',
      abilities: json['abilities'] ?? '',
      other: json['other'] ?? '',
      imageBytes: json['imageBytes'] != null
          ? Uint8List.fromList(List<int>.from(json['imageBytes']))
          : null,
      referenceImageBytes: json['referenceImageBytes'] != null
          ? Uint8List.fromList(List<int>.from(json['referenceImageBytes']))
          : null,
      customFields: (json['customFields'] as List?)?.map((e) =>
          CustomField(e['key'] ?? '', e['value'] ?? '')).toList() ?? [],
      additionalImages: (json['additionalImages'] as List?)?.map((e) =>
          Uint8List.fromList(List<int>.from(e))).toList() ?? [],
    );
  }
}
