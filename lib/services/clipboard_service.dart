import 'package:flutter/services.dart';

class ClipboardService {
  static Future<void> copyCharacterToClipboard({
    required String name,
    required int age,
    required String gender,
    String? raceName,
    required String biography,
    required String appearance,
    required String personality,
    required String abilities,
    required String other,
    required List<Map<String, String>> customFields,
  }) async {
    final buffer = StringBuffer()
      ..writeln('Имя: $name')
      ..writeln('Возраст: $age')
      ..writeln('Пол: $gender')
      ..writeln('Раса: ${raceName ?? "Не указана"}')
      ..writeln('Биография: $biography')
      ..writeln('Внешность: $appearance')
      ..writeln('Характер: $personality')
      ..writeln('Способности: $abilities')
      ..writeln('Прочее: $other');

    if (customFields.isNotEmpty) {
      buffer.writeln('\nДополнительные поля:');
      for (final field in customFields) {
        buffer.writeln('${field['key']}: ${field['value']}');
      }
    }

    await Clipboard.setData(ClipboardData(text: buffer.toString()));
  }
}