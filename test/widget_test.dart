import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_expense_tracker/views/home_screen.dart';

void main() {
  testWidgets('HomeScreen has a title and a bottom navigation bar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    // Verify that the title is present
    expect(find.text('Budget Tracker'), findsOneWidget);

    // Verify that the bottom navigation bar is present
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });

  testWidgets('HomeScreen displays expense list', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    // Verify that the expense list is present
    expect(find.byType(ListView), findsOneWidget);
  });
}
