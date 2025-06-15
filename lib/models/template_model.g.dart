// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'template_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuestionnaireTemplateAdapter extends TypeAdapter<QuestionnaireTemplate> {
  @override
  final int typeId = 4;

  @override
  QuestionnaireTemplate read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuestionnaireTemplate(
      name: fields[0] as String,
      standardFields: (fields[1] as List?)?.cast<String>(),
      customFields: (fields[2] as List?)?.cast<CustomField>(),
    );
  }

  @override
  void write(BinaryWriter writer, QuestionnaireTemplate obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.standardFields)
      ..writeByte(2)
      ..write(obj.customFields);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestionnaireTemplateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
