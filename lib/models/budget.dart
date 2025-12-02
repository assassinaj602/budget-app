import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'budget.g.dart';

@HiveType(typeId: 5)
class Budget {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String category;

  @HiveField(2)
  final double limit;

  @HiveField(3)
  final DateTime startDate;

  @HiveField(4)
  final DateTime endDate;

  @HiveField(5)
  final double alertThreshold; // 0.0 to 1.0 (percentage)

  @HiveField(6)
  final bool isActive;

  Budget({
    String? id,
    required this.category,
    required this.limit,
    required this.startDate,
    required this.endDate,
    this.alertThreshold = 0.8, // Alert at 80% by default
    this.isActive = true,
  }) : id = id ?? const Uuid().v4();

  bool get isExpired => DateTime.now().isAfter(endDate);

  bool get isMonthly {
    return endDate.difference(startDate).inDays >= 28 &&
        endDate.difference(startDate).inDays <= 31;
  }

  Budget copyWith({
    String? category,
    double? limit,
    DateTime? startDate,
    DateTime? endDate,
    double? alertThreshold,
    bool? isActive,
  }) {
    return Budget(
      id: id,
      category: category ?? this.category,
      limit: limit ?? this.limit,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      alertThreshold: alertThreshold ?? this.alertThreshold,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'limit': limit,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'alertThreshold': alertThreshold,
      'isActive': isActive,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      category: map['category'],
      limit: map['limit'],
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      alertThreshold: map['alertThreshold'] ?? 0.8,
      isActive: map['isActive'] ?? true,
    );
  }
}
