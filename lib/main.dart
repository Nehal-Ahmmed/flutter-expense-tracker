import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/providers/theme_provider.dart';
import 'package:untitled/providers/expense_provider.dart';
import 'package:untitled/providers/navigation_provider.dart';
import 'package:untitled/screens/auth%20screen/BiometricAuthScreen.dart';
import 'package:untitled/utils/theme.dart';
import 'package:untitled/screens/splash%20screen/splash_screen.dart';
import 'package:untitled/screens/main_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final biometricEnabled = prefs.getBool('biometric_enabled') ?? false;

  runApp(MyApp(initialBioMetricCheck: biometricEnabled));
}

/// [MyApp]
/// The root widget of the application.
class MyApp extends StatelessWidget {
  final bool initialBioMetricCheck;

  const MyApp({super.key, required this.initialBioMetricCheck});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..loadTheme()),
        ChangeNotifierProvider(
          create: (_) => ExpenseProvider()
            ..fetchTransactions()
            ..loadBudget(),
        ),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Expense Tracker',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const SplashScreen(nextScreen: MainWrapper()),
          );
        },
      ),
    );
  }
}
