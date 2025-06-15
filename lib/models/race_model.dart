import 'dart:typed_data';

import 'package:hive/hive.dart';

part 'race_model.g.dart';

@HiveType(typeId: 3)
class Race extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String description;

  @HiveField(2)
  String biology;

  @HiveField(3)
  String backstory;

  @HiveField(4)
  Uint8List? logo;

  Race({
    required this.name,
    this.description = '',
    this.biology = '',
    this.backstory = '',
    this.logo,
  });

  static Race empty() => Race(name: '', description: '');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Race &&
              runtimeType == other.runtimeType &&
              name == other.name;

  @override
  int get hashCode => name.hashCode;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'biology': biology,
      'backstory': backstory,
      'logo': logo?.toList(),
    };
  }

  factory Race.fromJson(Map<String, dynamic> json) {
    return Race(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      biology: json['biology'] ?? '',
      backstory: json['backstory'] ?? '',
      logo: json['logo'] != null
          ? Uint8List.fromList(List<int>.from(json['logo']))
          : null,
    );
  }
}