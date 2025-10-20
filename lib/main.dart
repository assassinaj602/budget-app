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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

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

  final prefs = await SharedPreferences.getInstance();
  final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

  runApp(
    ProviderScope(
      child: Consumer(
        builder: (context, ref, _) {
          final themeMode = ref.watch(themeProvider);
          return MaterialApp(
            theme: appTheme,
            darkTheme: darkAppTheme,
            themeMode: themeMode,
            home: seenOnboarding ? const SplashScreen() : const OnboardingScreen(),
            routes: {
              '/': (context) => const SplashScreen(),
              '/onboarding': (context) => const OnboardingScreen(),
            },
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    ),
  );
}
