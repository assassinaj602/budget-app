import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'views/theme/app_theme.dart';

import 'views/splash_screen.dart';
import 'views/onboarding/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/theme_provider_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/transaction.dart';
import 'models/category.dart';
import 'models/transaction_template.dart';
import 'models/recurring_transaction.dart';
import 'models/budget.dart';
import 'views/pin_lock_screen.dart';
import 'services/notification_service.dart';
import 'views/transactions_screen.dart';
import 'views/enhanced_reports_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  // Initialize local notifications for offline reminders
  await NotificationService().initialize();

  try {
    if (!Hive.isAdapterRegistered(TransactionAdapter().typeId)) {
      Hive.registerAdapter(TransactionAdapter());
    }
  } catch (e) {}
  try {
    if (!Hive.isAdapterRegistered(CategoryAdapter().typeId)) {
      Hive.registerAdapter(CategoryAdapter());
    }
  } catch (e) {
    print('CategoryAdapter registration error: $e');
  }
  try {
    if (!Hive.isAdapterRegistered(TransactionTemplateAdapter().typeId)) {
      Hive.registerAdapter(TransactionTemplateAdapter());
    }
  } catch (e) {
    print('TransactionTemplateAdapter registration error: $e');
  }
  try {
    if (!Hive.isAdapterRegistered(RecurringTransactionAdapter().typeId)) {
      Hive.registerAdapter(RecurringTransactionAdapter());
    }
  } catch (e) {
    print('RecurringTransactionAdapter registration error: $e');
  }
  try {
    if (!Hive.isAdapterRegistered(RecurrenceFrequencyAdapter().typeId)) {
      Hive.registerAdapter(RecurrenceFrequencyAdapter());
    }
  } catch (e) {
    print('RecurrenceFrequencyAdapter registration error: $e');
  }
  try {
    if (!Hive.isAdapterRegistered(BudgetAdapter().typeId)) {
      Hive.registerAdapter(BudgetAdapter());
    }
  } catch (e) {
    print('BudgetAdapter registration error: $e');
  }

  final prefs = await SharedPreferences.getInstance();
  final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

  runApp(
    ProviderScope(
      child: MyApp(seenOnboarding: seenOnboarding),
    ),
  );
}

class MyApp extends ConsumerWidget {
  final bool seenOnboarding;

  const MyApp({super.key, required this.seenOnboarding});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Budget Tracker',
      theme: appTheme,
      darkTheme: darkAppTheme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(seenOnboarding: seenOnboarding),
        '/onboarding': (context) => const OnboardingScreen(),
        '/pin_lock': (context) => const PinLockScreen(mode: PinMode.unlock),
        // Added named routes used by dashboard navigation buttons
        '/transactions': (context) => const TransactionsScreenWrapper(),
        '/enhanced_reports': (context) => const EnhancedReportsScreenWrapper(),
      },
    );
  }
}

// Lightweight wrappers to avoid direct heavy screen init during route table build.
class TransactionsScreenWrapper extends StatelessWidget {
  const TransactionsScreenWrapper({super.key});
  @override
  Widget build(BuildContext context) => const TransactionsScreen();
}

class EnhancedReportsScreenWrapper extends StatelessWidget {
  const EnhancedReportsScreenWrapper({super.key});
  @override
  Widget build(BuildContext context) => const EnhancedReportsScreen();
}
