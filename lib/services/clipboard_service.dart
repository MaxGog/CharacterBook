import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../generated/l10n.dart';

class ClipboardService {
  static Future<void> copyCharacterToClipboard({
    required BuildContext context,
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
    final s = S.of(context);
    final buffer = StringBuffer()
      ..writeln('${s.name}: $name')
      ..writeln('${s.age}: $age')
      ..writeln('${s.gender}: $gender')
      ..writeln('${s.race}: ${raceName ?? s.no_race}')
      ..writeln('${s.biography}: $biography')
      ..writeln('${s.appearance}: $appearance')
      ..writeln('${s.personality}: $personality')
      ..writeln('${s.abilities}: $abilities')
      ..writeln('${s.other}: $other');

    if (customFields.isNotEmpty) {
      buffer.writeln('\n${s.custom_fields}:');
      for (final field in customFields) {
        buffer.writeln('${field['key']}: ${field['value']}');
      }
    }

    await Clipboard.setData(ClipboardData(text: buffer.toString()));
  }

  static Future<void> copyRaceToClipboard({
    required BuildContext context,
    required String name,
    required String description,
    required String biology,
    required String backstory,
  }) async {
    final s = S.of(context);
    final buffer = StringBuffer()
      ..writeln('${s.race}: $name')
      ..writeln('\n${s.description}:')
      ..writeln(description)
      ..writeln('\n${s.biology}:')
      ..writeln(biology)
      ..writeln('\n${s.backstory}:')
      ..writeln(backstory);

    await Clipboard.setData(ClipboardData(text: buffer.toString()));
  }

  static Future<void> copyNoteToClipboard({
    required BuildContext context,
    required String content,
  }) async {
    final buffer = StringBuffer()
      ..writeln(content);

    await Clipboard.setData(ClipboardData(text: buffer.toString()));
  }
}