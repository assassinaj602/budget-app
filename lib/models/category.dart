import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 1)
class Category {
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          icon == other.icon &&
          color == other.color;

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ icon.hashCode ^ color.hashCode;

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int iconCode;

  @HiveField(3)
  final int colorValue;

  Category({
    required this.id,
    required this.name,
    required this.iconCode,
    required this.colorValue,
  });

  // Named constructor for convenience with IconData and Color
  Category.withIconAndColor({
    required this.id,
    required this.name,
    required IconData icon,
    required Color color,
  })  : iconCode = icon.codePoint,
        colorValue = color.toARGB32();

  IconData get icon => IconData(iconCode, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);

  factory Category.fromHive(Map<dynamic, dynamic> map) {
    return Category(
      id: map['id'] as String,
      name: map['name'] as String,
      iconCode: map['iconCode'] as int,
      colorValue: map['colorValue'] as int,
    );
  }
}
