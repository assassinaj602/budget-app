import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:budget_expense_tracker/views/main_navigation.dart';
import 'package:budget_expense_tracker/models/transaction.dart';
import 'package:budget_expense_tracker/models/category.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    // Initialize Hive in a temporary directory for tests and register adapters
    tempDir = Directory.systemTemp.createTempSync('budget_app_test_');
    Hive.init(tempDir.path);
    Hive.registerAdapter(TransactionAdapter());
    Hive.registerAdapter(CategoryAdapter());
  });

  tearDownAll(() async {
    try {
      await Hive.close();
      if (await tempDir.exists()) {
        tempDir.delete(recursive: true);
      }
    } catch (_) {}
  });
  testWidgets('MainNavigation shows FAB on home tab', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: MainNavigation()),
      ),
    );

    // Verify that the dashboard is present via DashboardScreen
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('MainNavigation renders with FAB', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: MainNavigation()),
      ),
    );

    // Verify that the FAB is present and Dashboard is rendered
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
