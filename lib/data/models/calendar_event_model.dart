import 'package:characterbook/data/enums/calendar_event_type_enum.dart';
import 'package:characterbook/data/models/custom_event_model.dart';
import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/data/models/character_model.dart';
import 'package:characterbook/data/models/note_model.dart';
import 'package:characterbook/data/models/race_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarEventModel {
  final DateTime date;
  final CalendarEventType type;
  final Character? character;
  final Race? race;
  final Note? note;
  final CustomEvent? customEvent;

  const CalendarEventModel._({
    required this.date,
    required this.type,
    this.character,
    this.race,
    this.note,
    this.customEvent
  });

  factory CalendarEventModel.character(DateTime date, Character character) =>
      CalendarEventModel._(
        date: date,
        type: CalendarEventType.character,
        character: character,
      );

  factory CalendarEventModel.race(DateTime date, Race race) =>
    CalendarEventModel._(
      date: date,
      type: CalendarEventType.race,
      race: race,
    );

  factory CalendarEventModel.note(DateTime date, Note note) => 
    CalendarEventModel._(
      date: date,
      type: CalendarEventType.note,
      note: note,
    );

  factory CalendarEventModel.custom(DateTime date, CustomEvent event) =>
      CalendarEventModel._(
        date: date,
        type: CalendarEventType.custom,
        customEvent: event,
      );

  String getTitle(BuildContext context) {
    switch (type) {
      case CalendarEventType.character:
        return character?.name ?? S.of(context).character;
      case CalendarEventType.race:
        return race?.name ?? S.of(context).race;
      case CalendarEventType.note:
        return note?.title ?? S.of(context).posts;
      case CalendarEventType.custom:
        return customEvent?.title ?? S.of(context).custom_event;
    }
  }

  String getSubtitle(BuildContext context) {
    final time = DateFormat('HH:mm').format(date);
    switch (type) {
      case CalendarEventType.character:
        return '${S.of(context).character} • $time';
      case CalendarEventType.race:
        return '${S.of(context).race} • $time';
      case CalendarEventType.note:
        return '${S.of(context).posts} • $time';
      case CalendarEventType.custom:
        return '${customEvent?.title ?? ""} • $time';
    }
  }

  IconData get icon {
    switch (type) {
      case CalendarEventType.character:
        return Icons.person;
      case CalendarEventType.race:
        return Icons.flag;
      case CalendarEventType.note:
        return Icons.note;
      case CalendarEventType.custom:
        return Icons.event;
    }
  }

  Color getColor(BuildContext context) {
    switch (type) {
      case CalendarEventType.character:
        return Theme.of(context).colorScheme.primary;
      case CalendarEventType.race:
        return Theme.of(context).colorScheme.secondary;
      case CalendarEventType.note:
        return Theme.of(context).colorScheme.tertiary;
      case CalendarEventType.custom:
        return Theme.of(context).colorScheme.tertiary;
    }
  }
}
