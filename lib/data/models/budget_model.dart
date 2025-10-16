import 'package:hive/hive.dart';
import '../../domain/entities/budget_entity.dart';

part 'budget_model.g.dart';

@HiveType(typeId: 2)
class BudgetModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final String? categoryId;

  @HiveField(4)
  final DateTime startDate;

  @HiveField(5)
  final DateTime endDate;

  @HiveField(6)
  final String period;

  @HiveField(7)
  final bool notifyOnLimit;

  @HiveField(8)
  final double notifyPercentage;

  BudgetModel({
    required this.id,
    required this.name,
    required this.amount,
    this.categoryId,
    required this.startDate,
    required this.endDate,
    required this.period,
    this.notifyOnLimit = true,
    this.notifyPercentage = 80.0,
  });

  /// Convert to domain entity
  BudgetEntity toEntity() {
    return BudgetEntity(
      id: id,
      name: name,
      amount: amount,
      categoryId: categoryId,
      startDate: startDate,
      endDate: endDate,
      period: period,
      notifyOnLimit: notifyOnLimit,
      notifyPercentage: notifyPercentage,
    );
  }

  /// Create from domain entity
  factory BudgetModel.fromEntity(BudgetEntity entity) {
    return BudgetModel(
      id: entity.id,
      name: entity.name,
      amount: entity.amount,
      categoryId: entity.categoryId,
      startDate: entity.startDate,
      endDate: entity.endDate,
      period: entity.period,
      notifyOnLimit: entity.notifyOnLimit,
      notifyPercentage: entity.notifyPercentage,
    );
  }

  /// From JSON
  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] as String,
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['categoryId'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      period: json['period'] as String,
      notifyOnLimit: json['notifyOnLimit'] as bool? ?? true,
      notifyPercentage: (json['notifyPercentage'] as num?)?.toDouble() ?? 80.0,
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'categoryId': categoryId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'period': period,
      'notifyOnLimit': notifyOnLimit,
      'notifyPercentage': notifyPercentage,
    };
  }
}
