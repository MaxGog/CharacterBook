import 'package:hive/hive.dart';

part 'custom_field_model.g.dart';

@HiveType(typeId: 1)
class CustomField {
  @HiveField(0)
  final String key;

  @HiveField(1)
  final String value;

  CustomField(this.key, this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is CustomField &&
              runtimeType == other.runtimeType &&
              key == other.key &&
              value == other.value;

  @override
  int get hashCode => key.hashCode ^ value.hashCode;

  @override
  String toString() => 'CustomField{key: $key, value: $value}';

  CustomField copyWith({
    String? key,
    String? value,
  }) {
    return CustomField(
      key ?? this.key,
      value ?? this.value,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'value': value,
    };
  }

  factory CustomField.fromJson(Map<String, dynamic> json) {
    return CustomField(
      json['key'],
      json['value'],
    );
  }
}