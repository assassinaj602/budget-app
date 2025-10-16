import 'package:flutter/material.dart';
import '../views/home_screen.dart';
import '../views/transactions_screen.dart';
import '../views/reports_screen.dart';
import '../views/settings_screen.dart';

class NavigationHelper {
  static void navigateToScreen(BuildContext context, int index) {
    if (!context.mounted) return;

    Widget screen;
    switch (index) {
      case 0:
        screen = const HomeScreen();
        break;
      case 1:
        screen = const TransactionsScreen();
        break;
      case 2:
        screen = const ReportsScreen();
        break;
      case 3:
        screen = const SettingsScreen();
        break;
      default:
        screen = const HomeScreen();
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionDuration: Duration.zero,
      ),
    );
  }
}
