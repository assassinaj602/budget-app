import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Domain entity for Category
class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final String type; // 'income' or 'expense' or 'both'

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.type = 'both',
  });

  @override
  List<Object?> get props => [id, name, icon, color, type];

  CategoryEntity copyWith({
    String? id,
    String? name,
    IconData? icon,
    Color? color,
    String? type,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
    );
  }
}
