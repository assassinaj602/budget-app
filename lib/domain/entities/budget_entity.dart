import 'package:equatable/equatable.dart';

/// Domain entity for Budget
class BudgetEntity extends Equatable {
  final String id;
  final String name;
  final double amount;
  final String? categoryId; // null means overall budget
  final DateTime startDate;
  final DateTime endDate;
  final String period; // 'monthly', 'weekly', 'yearly', 'custom'
  final bool notifyOnLimit; // Notify when budget is reached
  final double
      notifyPercentage; // Notify when X% of budget is reached (default 80%)

  const BudgetEntity({
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

  @override
  List<Object?> get props => [
        id,
        name,
        amount,
        categoryId,
        startDate,
        endDate,
        period,
        notifyOnLimit,
        notifyPercentage,
      ];

  BudgetEntity copyWith({
    String? id,
    String? name,
    double? amount,
    String? categoryId,
    DateTime? startDate,
    DateTime? endDate,
    String? period,
    bool? notifyOnLimit,
    double? notifyPercentage,
  }) {
    return BudgetEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      period: period ?? this.period,
      notifyOnLimit: notifyOnLimit ?? this.notifyOnLimit,
      notifyPercentage: notifyPercentage ?? this.notifyPercentage,
    );
  }
}
