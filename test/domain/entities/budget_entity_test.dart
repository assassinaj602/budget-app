import 'package:flutter_test/flutter_test.dart';
import 'package:budget_expense_tracker/domain/entities/budget_entity.dart';

void main() {
  group('BudgetEntity', () {
    test('should create a budget with all required fields', () {
      // Arrange
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 1, 31);

      final budget = BudgetEntity(
        id: '1',
        name: 'Monthly Food Budget',
        amount: 500.0,
        startDate: startDate,
        endDate: endDate,
        period: 'monthly',
      );

      // Assert
      expect(budget.id, '1');
      expect(budget.name, 'Monthly Food Budget');
      expect(budget.amount, 500.0);
      expect(budget.startDate, startDate);
      expect(budget.endDate, endDate);
      expect(budget.period, 'monthly');
    });

    test('should have default notification settings', () {
      // Arrange
      final budget = BudgetEntity(
        id: '1',
        name: 'Test Budget',
        amount: 1000.0,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        period: 'monthly',
      );

      // Assert
      expect(budget.notifyOnLimit, true);
      expect(budget.notifyPercentage, 80.0);
    });

    test('should support custom notification settings', () {
      // Arrange
      final budget = BudgetEntity(
        id: '1',
        name: 'Test Budget',
        amount: 1000.0,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        period: 'monthly',
        notifyOnLimit: false,
        notifyPercentage: 90.0,
      );

      // Assert
      expect(budget.notifyOnLimit, false);
      expect(budget.notifyPercentage, 90.0);
    });

    test('should support category-specific budgets', () {
      // Arrange
      final budget = BudgetEntity(
        id: '1',
        name: 'Food Budget',
        amount: 500.0,
        categoryId: 'food_cat_id',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        period: 'monthly',
      );

      // Assert
      expect(budget.categoryId, 'food_cat_id');
    });

    test('should create copy with modified fields', () {
      // Arrange
      final budget = BudgetEntity(
        id: '1',
        name: 'Original Budget',
        amount: 500.0,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        period: 'monthly',
      );

      // Act
      final modified = budget.copyWith(
        name: 'Modified Budget',
        amount: 750.0,
      );

      // Assert
      expect(modified.name, 'Modified Budget');
      expect(modified.amount, 750.0);
      expect(modified.id, budget.id);
      expect(modified.period, budget.period);
    });

    test('should support different period types', () {
      // Test weekly budget
      final weeklyBudget = BudgetEntity(
        id: '1',
        name: 'Weekly Budget',
        amount: 200.0,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 7),
        period: 'weekly',
      );
      expect(weeklyBudget.period, 'weekly');

      // Test yearly budget
      final yearlyBudget = BudgetEntity(
        id: '2',
        name: 'Yearly Budget',
        amount: 12000.0,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        period: 'yearly',
      );
      expect(yearlyBudget.period, 'yearly');

      // Test custom budget
      final customBudget = BudgetEntity(
        id: '3',
        name: 'Custom Budget',
        amount: 1500.0,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 3, 31),
        period: 'custom',
      );
      expect(customBudget.period, 'custom');
    });
  });
}
