import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'recurring_transaction.g.dart';

enum RecurrenceFrequency {
  daily,
  weekly,
  biweekly,
  monthly,
  quarterly,
  yearly,
}

@HiveType(typeId: 3)
class RecurringTransaction {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final String category;

  @HiveField(4)
  final String type;

  @HiveField(5)
  final String? note;

  @HiveField(6)
  final RecurrenceFrequency frequency;

  @HiveField(7)
  final DateTime startDate;

  @HiveField(8)
  final DateTime? endDate;

  @HiveField(9)
  final DateTime lastGenerated;

  @HiveField(10)
  final bool isActive;

  RecurringTransaction({
    String? id,
    required this.title,
    required this.amount,
    required this.category,
    required this.type,
    this.note,
    required this.frequency,
    required this.startDate,
    this.endDate,
    DateTime? lastGenerated,
    this.isActive = true,
  })  : id = id ?? const Uuid().v4(),
        lastGenerated = lastGenerated ?? DateTime.now();

  DateTime? get nextDueDate {
    if (!isActive || (endDate != null && DateTime.now().isAfter(endDate!))) {
      return null;
    }

    DateTime next = lastGenerated;

    switch (frequency) {
      case RecurrenceFrequency.daily:
        next = next.add(const Duration(days: 1));
        break;
      case RecurrenceFrequency.weekly:
        next = next.add(const Duration(days: 7));
        break;
      case RecurrenceFrequency.biweekly:
        next = next.add(const Duration(days: 14));
        break;
      case RecurrenceFrequency.monthly:
        next = DateTime(next.year, next.month + 1, next.day);
        break;
      case RecurrenceFrequency.quarterly:
        next = DateTime(next.year, next.month + 3, next.day);
        break;
      case RecurrenceFrequency.yearly:
        next = DateTime(next.year + 1, next.month, next.day);
        break;
    }

    return next;
  }

  bool get isDue {
    final next = nextDueDate;
    return next != null && DateTime.now().isAfter(next);
  }

  RecurringTransaction copyWith({
    String? title,
    double? amount,
    String? category,
    String? type,
    String? note,
    RecurrenceFrequency? frequency,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? lastGenerated,
    bool? isActive,
  }) {
    return RecurringTransaction(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      type: type ?? this.type,
      note: note ?? this.note,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      lastGenerated: lastGenerated ?? this.lastGenerated,
      isActive: isActive ?? this.isActive,
    );
  }
}
