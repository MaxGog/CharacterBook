import 'package:hive/hive.dart';
import '../models/custom_field_model.dart';

class CustomFieldAdapter extends TypeAdapter<CustomField> {
  @override
  final int typeId = 1;

  @override
  CustomField read(BinaryReader reader) {
    final key = reader.readString();
    final value = reader.readString();
    return CustomField(key, value);
  }

  @override
  void write(BinaryWriter writer, CustomField obj) {
    writer.writeString(obj.key);
    writer.writeString(obj.value);
  }
}