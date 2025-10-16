import 'package:flutter_test/flutter_test.dart';
import 'package:budget_expense_tracker/domain/entities/transaction_entity.dart';

void main() {
  group('TransactionEntity', () {
    test('should create a transaction with all required fields', () {
      // Arrange
      final transaction = TransactionEntity(
        id: '1',
        title: 'Grocery Shopping',
        amount: 50.0,
        date: DateTime(2024, 1, 1),
        category: 'Food',
        type: 'expense',
      );

      // Assert
      expect(transaction.id, '1');
      expect(transaction.title, 'Grocery Shopping');
      expect(transaction.amount, 50.0);
      expect(transaction.category, 'Food');
      expect(transaction.type, 'expense');
    });

    test('should support value equality', () {
      // Arrange
      final transaction1 = TransactionEntity(
        id: '1',
        title: 'Test',
        amount: 100.0,
        date: DateTime(2024, 1, 1),
        category: 'Food',
        type: 'expense',
      );

      final transaction2 = TransactionEntity(
        id: '1',
        title: 'Test',
        amount: 100.0,
        date: DateTime(2024, 1, 1),
        category: 'Food',
        type: 'expense',
      );

      // Assert
      expect(transaction1, equals(transaction2));
    });

    test('should create copy with modified fields', () {
      // Arrange
      final transaction = TransactionEntity(
        id: '1',
        title: 'Original',
        amount: 100.0,
        date: DateTime(2024, 1, 1),
        category: 'Food',
        type: 'expense',
      );

      // Act
      final modified = transaction.copyWith(
        title: 'Modified',
        amount: 150.0,
      );

      // Assert
      expect(modified.title, 'Modified');
      expect(modified.amount, 150.0);
      expect(modified.id, transaction.id);
      expect(modified.category, transaction.category);
    });

    test('should handle optional fields correctly', () {
      // Arrange
      final transaction = TransactionEntity(
        id: '1',
        title: 'Test',
        amount: 100.0,
        date: DateTime(2024, 1, 1),
        category: 'Food',
        type: 'expense',
        note: 'Test note',
        receiptPath: '/path/to/receipt.jpg',
      );

      // Assert
      expect(transaction.note, 'Test note');
      expect(transaction.receiptPath, '/path/to/receipt.jpg');
    });

    test('should handle recurring transaction fields', () {
      // Arrange
      final transaction = TransactionEntity(
        id: '1',
        title: 'Salary',
        amount: 5000.0,
        date: DateTime(2024, 1, 1),
        category: 'Income',
        type: 'income',
        isRecurring: true,
        recurringPattern: 'monthly',
        recurringEndDate: DateTime(2024, 12, 31),
      );

      // Assert
      expect(transaction.isRecurring, true);
      expect(transaction.recurringPattern, 'monthly');
      expect(transaction.recurringEndDate, DateTime(2024, 12, 31));
    });
  });
}
