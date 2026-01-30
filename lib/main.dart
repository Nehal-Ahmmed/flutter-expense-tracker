import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/providers/theme_provider.dart';
import 'package:untitled/providers/expense_provider.dart';
import 'package:untitled/providers/navigation_provider.dart';
import 'package:untitled/utils/theme.dart';
import 'package:untitled/screens/splash_screen.dart';
import 'package:untitled/screens/main_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

/// [MyApp]
/// The root widget of the application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..loadTheme()),
        ChangeNotifierProvider(
          create: (_) => ExpenseProvider()..fetchTransactions(),
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
