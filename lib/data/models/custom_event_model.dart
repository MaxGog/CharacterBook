import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'custom_event_model.g.dart';

@HiveType(typeId: 13)
class CustomEvent extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final bool hasReminder;

  @HiveField(5)
  final int reminderMinutesBefore;

  @HiveField(6)
  final bool addedToDeviceCalendar;

  @HiveField(7)
  final String? deviceCalendarEventId;

  CustomEvent({
    String? id,
    required this.title,
    this.description = '',
    required this.date,
    this.hasReminder = false,
    this.reminderMinutesBefore = 15,
    this.addedToDeviceCalendar = false,
    this.deviceCalendarEventId,
  }) : id = id ?? const Uuid().v4();

  CustomEvent copyWith({
    String? title,
    String? description,
    DateTime? date,
    bool? hasReminder,
    int? reminderMinutesBefore,
    bool? addedToDeviceCalendar,
    String? deviceCalendarEventId,
  }) {
    return CustomEvent(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      hasReminder: hasReminder ?? this.hasReminder,
      reminderMinutesBefore:
          reminderMinutesBefore ?? this.reminderMinutesBefore,
      addedToDeviceCalendar:
          addedToDeviceCalendar ?? this.addedToDeviceCalendar,
      deviceCalendarEventId:
          deviceCalendarEventId ?? this.deviceCalendarEventId,
    );
  }
}
