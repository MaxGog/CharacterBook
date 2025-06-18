import 'dart:typed_data';

import 'package:characterbook/models/race_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';

import '../generated/l10n.dart';
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

  @HiveField(12)
  DateTime lastEdited;

  @HiveField(13)
  Race? race;

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
    this.race,
    List<CustomField>? customFields,
    List<Uint8List>? additionalImages,
    DateTime? lastEdited,
  }) :
      customFields = customFields ?? [],
      additionalImages = additionalImages ?? [],
      lastEdited = lastEdited ?? DateTime.now();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Character &&
              runtimeType == other.runtimeType &&
              name == other.name &&
              age == other.age;

  @override
  int get hashCode => name.hashCode ^ age.hashCode;


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
      'lastEdited': lastEdited.toIso8601String(),
      'race': race?.name,
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
      lastEdited: json['lastEdited'] != null
          ? DateTime.parse(json['lastEdited'])
          : DateTime.now(),
      race: json['race'] != null ? Race(name: json['race']) : null,
    );
  }

  void updateLastEdited() {
    lastEdited = DateTime.now();
  }

  factory Character.empty() {
    return Character(
      name: '',
      age: 20,
      gender: 'male',
      biography: '',
      personality: '',
      appearance: '',
      abilities: '',
      other: '',
      imageBytes: null,
      referenceImageBytes: null,
      customFields: [],
      additionalImages: [],
      race: null,
    );
  }

  Character copyWith({
    String? name,
    int? age,
    String? gender,
    String? biography,
    String? personality,
    String? appearance,
    String? abilities,
    String? other,
    Uint8List? imageBytes,
    Uint8List? referenceImageBytes,
    List<CustomField>? customFields,
    List<Uint8List>? additionalImages,
    Race? race,
  }) {
    return Character(
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      biography: biography ?? this.biography,
      personality: personality ?? this.personality,
      appearance: appearance ?? this.appearance,
      abilities: abilities ?? this.abilities,
      other: other ?? this.other,
      imageBytes: imageBytes ?? this.imageBytes,
      referenceImageBytes: referenceImageBytes ?? this.referenceImageBytes,
      customFields: customFields ?? this.customFields,
      additionalImages: additionalImages ?? this.additionalImages,
      race: race ?? this.race,
    );
  }
}
