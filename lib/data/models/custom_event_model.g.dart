// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_event_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomEventAdapter extends TypeAdapter<CustomEvent> {
  @override
  final int typeId = 13;

  @override
  CustomEvent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomEvent(
      id: fields[0] as String?,
      title: fields[1] as String,
      description: fields[2] as String,
      date: fields[3] as DateTime,
      hasReminder: fields[4] as bool,
      reminderMinutesBefore: fields[5] as int,
      addedToDeviceCalendar: fields[6] as bool,
      deviceCalendarEventId: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CustomEvent obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.hasReminder)
      ..writeByte(5)
      ..write(obj.reminderMinutesBefore)
      ..writeByte(6)
      ..write(obj.addedToDeviceCalendar)
      ..writeByte(7)
      ..write(obj.deviceCalendarEventId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomEventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
