import 'dart:math';

import 'package:hive/hive.dart';

part 'note_model.g.dart';

@HiveType(typeId: 2)
class Note extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String content;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  DateTime updatedAt;

  @HiveField(5, defaultValue: [])
  List<String> characterIds;

  @HiveField(6)
  List<String> tags;

  @HiveField(7)
  String? folderId;

  Note({
    String? id,
    required this.title,
    required this.content,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.tags = const [],
    this.characterIds = const [],
    required this.folderId,
  })  : id = (id == null || id.isEmpty) ? _generateUniqueId() : id,
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'characterIds': characterIds,
    'folderId': folderId,
  };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
    id: json['id'],
    title: json['title'],
    content: json['content'],
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
    characterIds: List<String>.from(json['characterIds'] ?? []),
    folderId: json['folderId']
  );

  static String _generateUniqueId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(1000000);
    return '${timestamp}_$random';
  }

  Note copyWith({
    String? id,
    String? title,
    String? content,
    String? folderId
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      folderId: folderId ?? this.folderId,
    );
  }
}