import 'package:equatable/equatable.dart';

/// Domain entity for Transaction
class TransactionEntity extends Equatable {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final String type; // 'income' or 'expense'
  final String? note;
  final String? receiptPath;
  final bool isRecurring;
  final String? recurringPattern; // 'daily', 'weekly', 'monthly', 'yearly'
  final DateTime? recurringEndDate;

  const TransactionEntity({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.type,
    this.note,
    this.receiptPath,
    this.isRecurring = false,
    this.recurringPattern,
    this.recurringEndDate,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        amount,
        date,
        category,
        type,
        note,
        receiptPath,
        isRecurring,
        recurringPattern,
        recurringEndDate,
      ];

  TransactionEntity copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    String? category,
    String? type,
    String? note,
    String? receiptPath,
    bool? isRecurring,
    String? recurringPattern,
    DateTime? recurringEndDate,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      type: type ?? this.type,
      note: note ?? this.note,
      receiptPath: receiptPath ?? this.receiptPath,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringPattern: recurringPattern ?? this.recurringPattern,
      recurringEndDate: recurringEndDate ?? this.recurringEndDate,
    );
  }
}
