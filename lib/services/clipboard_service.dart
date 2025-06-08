import 'package:flutter/services.dart';

class ClipboardService {
  static Future<void> copyCharacterToClipboard({
    required String name,
    required int age,
    required String gender,
    required String? raceName,
    required String biography,
    required String appearance,
    required String personality,
    required String abilities,
    required String other,
    required List<Map<String, String>> customFields,
  }) async {
    var characterInfo = '''
Имя: $name
Возраст: $age
Пол: $gender
Раса: ${raceName ?? 'Не указана'}
Биография: $biography
Внешность: $appearance
Характер: $personality
Способности: $abilities
Прочее: $other
''';

    for (var field in customFields) {
      if (field['key']?.isNotEmpty ?? false) {
        characterInfo += '${field['key']}: ${field['value']}\n';
      }
    }

    await Clipboard.setData(ClipboardData(text: characterInfo));
  }
}