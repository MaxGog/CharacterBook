import 'package:characterbook/data/models/custom_field_model.dart';
import 'package:characterbook/data/models/race_model.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

part 'character_model.g.dart';

@HiveType(typeId: 0)
class Character extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int age;

  @HiveField(3)
  String gender;

  @HiveField(4)
  String biography;

  @HiveField(5)
  String personality;

  @HiveField(6)
  String appearance;

  @HiveField(7)
  Uint8List? imageBytes; // Основное изображение (портрет)

  @HiveField(8)
  String abilities;

  @HiveField(9)
  String other;

  @HiveField(10)
  Uint8List? referenceImageBytes; // Дополнительное изображение референс

  @HiveField(11)
  List<CustomField> customFields;

  @HiveField(12)
  List<Uint8List> additionalImages;

  @HiveField(13)
  DateTime lastEdited;

  @HiveField(14)
  Race? race;

  @HiveField(15)
  String? folderId;

  @HiveField(16, defaultValue: [])
  List<String> tags;

  Character({
    String? id,
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
    List<String> tags = const [],
    List<CustomField>? customFields,
    List<Uint8List>? additionalImages,
    DateTime? lastEdited,
    this.folderId,
  })  : id = (id == null || id.isEmpty) ? _generateUniqueId() : id,
        customFields = customFields ?? [],
        additionalImages = additionalImages ?? [],
        lastEdited = lastEdited ?? DateTime.now(),
        tags = List.from(tags);

  /// Генерирует уникальный идентификатор на основе времени и случайного числа.
  static String _generateUniqueId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecond;
    return '${timestamp}_$random';
  }

  /// Сериализация в JSON для экспорта.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
      'customFields':
          customFields.map((f) => {'key': f.key, 'value': f.value}).toList(),
      'additionalImages': additionalImages.map((img) => img.toList()).toList(),
      'lastEdited': lastEdited.toIso8601String(),
      'race': race?.name,
      'raceId': race?.id,
      'folderId': folderId,
      'tags': tags,
    };
  }

  /// Десериализация из JSON.
  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: (json['id'] as String?)?.isNotEmpty == true
          ? json['id']
          : _generateUniqueId(),
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
      customFields: (json['customFields'] as List?)
              ?.map((e) => CustomField(e['key'] ?? '', e['value'] ?? ''))
              .toList() ??
          [],
      additionalImages: (json['additionalImages'] as List?)
              ?.map((e) => Uint8List.fromList(List<int>.from(e)))
              .toList() ??
          [],
      lastEdited: json['lastEdited'] != null
          ? DateTime.parse(json['lastEdited'])
          : DateTime.now(),
      race: json['race'] != null
          ? Race(id: json['raceId'], name: json['race'])
          : null,
      folderId: json['folderId'],
      tags: (json['tags'] as List?)?.cast<String>() ?? [],
    );
  }

  void updateLastEdited() {
    lastEdited = DateTime.now();
  }

  factory Character.empty() {
    return Character(
      id: '',
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
      tags: [],
    );
  }

  Character copyWith({
    String? id,
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
    String? folderId,
    List<String>? tags,
  }) {
    return Character(
      id: id ?? this.id,
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
      customFields: customFields != null
          ? customFields.map((f) => f.copyWith()).toList()
          : this.customFields.map((f) => f.copyWith()).toList(),
      additionalImages: additionalImages ?? List.from(this.additionalImages),
      race: race != null
          ? Race(id: race.id, name: race.name)
          : (this.race != null
              ? Race(id: this.race!.id, name: this.race!.name)
              : null),
      folderId: folderId ?? this.folderId,
      tags: tags ?? List.from(this.tags),
      lastEdited: DateTime.now(),
    );
  }

  Map<String, dynamic> toExportMap() {
    return {
      'type': 'character',
      'id': id,
      'name': name,
      'description': biography,
      'mainImage': mainImage, // используем согласованный геттер
      'additionalImages': additionalImages,
      'tags': tags,
      'lastEdited': lastEdited,
      'details': {
        'age': age,
        'gender': gender,
        'biography': biography,
        'personality': personality,
        'appearance': appearance,
        'abilities': abilities,
        'other': other,
        'race': race?.name,
        'customFields':
            customFields.map((f) => {'key': f.key, 'value': f.value}).toList(),
        'referenceImage': referenceImageBytes,
      }
    };
  }

  String get modelType => 'character';

  String get description => biography;

  Uint8List? get mainImage => imageBytes ?? referenceImageBytes;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Character && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
