import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'transaction_template.g.dart';

@HiveType(typeId: 2)
class TransactionTemplate {
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
  final bool isDefault;

  TransactionTemplate({
    String? id,
    required this.title,
    required this.amount,
    required this.category,
    required this.type,
    this.note,
    this.isDefault = false,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'type': type,
      'note': note,
      'isDefault': isDefault,
    };
  }

  factory TransactionTemplate.fromMap(Map<String, dynamic> map) {
    return TransactionTemplate(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      category: map['category'],
      type: map['type'],
      note: map['note'],
      isDefault: map['isDefault'] ?? false,
    );
  }
}
