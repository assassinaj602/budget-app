import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'views/theme/app_theme.dart';

import 'views/splash_screen.dart';
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

  runApp(
    ProviderScope(
      child: Consumer(
        builder: (context, ref, _) {
          final themeMode = ref.watch(themeProvider);
          return MaterialApp(
            theme: appTheme,
            darkTheme: darkAppTheme,
            themeMode: themeMode,
            home: const SplashScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    ),
  );
}
