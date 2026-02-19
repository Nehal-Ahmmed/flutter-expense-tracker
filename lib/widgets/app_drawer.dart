import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/providers/theme_provider.dart';
import 'package:untitled/screens/settings%20screen/settings_screen.dart';
import 'package:untitled/utils/theme.dart';

/// [AppDrawer]
/// A side navigation drawer.
///
/// Compose Comparison: similar to `ModalNavigationDrawer`.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: AppTheme.primaryColor),
            accountName: const Text(
              "User Name",
              style: TextStyle(fontWeight: FontWeight.bold),
            ), // Placeholder
            accountEmail: const Text("user@example.com"),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                "U",
                style: TextStyle(fontSize: 24, color: AppTheme.primaryColor),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context); // Close drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to Settings if not already there
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              // Handle Logout
            },
          ),
        ],
      ),
    );
  }
}
