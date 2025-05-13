import 'dart:typed_data';

import 'package:hive/hive.dart';

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

  Character({
    required this.name,
    required this.age,
    required this.gender,
    required this.biography,
    required this.personality,
    required this.appearance,
    required this.abilities,
    required this.other,

    this.imageBytes,
    this.referenceImageBytes,
  });
}