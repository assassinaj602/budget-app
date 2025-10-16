import 'package:hive/hive.dart';
import '../../domain/entities/transaction_entity.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 0)
class TransactionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String category;

  @HiveField(5)
  final String type;

  @HiveField(6)
  final String? note;

  @HiveField(7)
  final String? receiptPath;

  @HiveField(8)
  final bool isRecurring;

  @HiveField(9)
  final String? recurringPattern;

  @HiveField(10)
  final DateTime? recurringEndDate;

  TransactionModel({
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

  /// Convert to domain entity
  TransactionEntity toEntity() {
    return TransactionEntity(
      id: id,
      title: title,
      amount: amount,
      date: date,
      category: category,
      type: type,
      note: note,
      receiptPath: receiptPath,
      isRecurring: isRecurring,
      recurringPattern: recurringPattern,
      recurringEndDate: recurringEndDate,
    );
  }

  /// Create from domain entity
  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      title: entity.title,
      amount: entity.amount,
      date: entity.date,
      category: entity.category,
      type: entity.type,
      note: entity.note,
      receiptPath: entity.receiptPath,
      isRecurring: entity.isRecurring,
      recurringPattern: entity.recurringPattern,
      recurringEndDate: entity.recurringEndDate,
    );
  }

  /// From JSON
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      category: json['category'] as String,
      type: json['type'] as String,
      note: json['note'] as String?,
      receiptPath: json['receiptPath'] as String?,
      isRecurring: json['isRecurring'] as bool? ?? false,
      recurringPattern: json['recurringPattern'] as String?,
      recurringEndDate: json['recurringEndDate'] != null
          ? DateTime.parse(json['recurringEndDate'] as String)
          : null,
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
      'type': type,
      'note': note,
      'receiptPath': receiptPath,
      'isRecurring': isRecurring,
      'recurringPattern': recurringPattern,
      'recurringEndDate': recurringEndDate?.toIso8601String(),
    };
  }
}
