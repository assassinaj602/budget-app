import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'transaction.g.dart';

@HiveType(typeId: 0)
class Transaction {
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

  Transaction({
    String? id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.type,
    this.note,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
      'type': type,
      'note': note,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      category: map['category'],
      type: map['type'],
      note: map['note'],
    );
  }
}
