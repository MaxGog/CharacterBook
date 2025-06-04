// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CharacterAdapter extends TypeAdapter<Character> {
  @override
  final int typeId = 0;

  @override
  Character read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Character(
      name: fields[0] as String,
      age: fields[1] as int,
      gender: fields[2] as String,
      biography: fields[3] as String,
      personality: fields[4] as String,
      appearance: fields[5] as String,
      abilities: fields[7] as String,
      other: fields[8] as String,
      imageBytes: fields[6] as Uint8List?,
      referenceImageBytes: fields[9] as Uint8List?,
      customFields: (fields[10] as List?)?.cast<CustomField>(),
      additionalImages: (fields[11] as List?)?.cast<Uint8List>(),
      lastEdited: fields[12] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Character obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.age)
      ..writeByte(2)
      ..write(obj.gender)
      ..writeByte(3)
      ..write(obj.biography)
      ..writeByte(4)
      ..write(obj.personality)
      ..writeByte(5)
      ..write(obj.appearance)
      ..writeByte(6)
      ..write(obj.imageBytes)
      ..writeByte(7)
      ..write(obj.abilities)
      ..writeByte(8)
      ..write(obj.other)
      ..writeByte(9)
      ..write(obj.referenceImageBytes)
      ..writeByte(10)
      ..write(obj.customFields)
      ..writeByte(11)
      ..write(obj.additionalImages)
      ..writeByte(12)
      ..write(obj.lastEdited);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CharacterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
