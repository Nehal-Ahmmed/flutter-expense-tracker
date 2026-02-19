import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/providers/navigation_provider.dart';
import 'package:untitled/screens/home_screen.dart';
import 'package:untitled/screens/planning_screen.dart'; // Placeholder
import 'package:untitled/screens/expense_screen.dart'; // Placeholder
import 'package:untitled/screens/settings%20screen/settings_screen.dart'; // Placeholder
import 'package:untitled/widgets/app_drawer.dart';

/// [MainWrapper]
/// The main shell of the application containing the [BottomNavigationBar] and [Drawer].
///
/// Comparison: This replaces the previous `MainScreen` wrapper logic.
class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  // int _currentIndex = 0; // Removed as NavigationProvider will manage this

  // List of screens for bottom navigation
  final List<Widget> _screens = [
    const HomeScreen(),
    const ExpenseScreen(),
    const PlanningScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);

    return Scaffold(
      // Drawer is defined here in the Scaffold
      drawer: const AppDrawer(),
      body: _screens[navigationProvider.currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationProvider.currentIndex,
        onDestinationSelected: (index) {
          navigationProvider.setIndex(index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Expenses',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline_rounded),
            selectedIcon: Icon(Icons.pie_chart_rounded),
            label: 'Planning',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
