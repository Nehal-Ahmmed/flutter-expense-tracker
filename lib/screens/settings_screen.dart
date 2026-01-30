import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:untitled/providers/theme_provider.dart';
import 'package:untitled/services/export_service.dart';
import 'package:untitled/utils/theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'User Name',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'user@email.com',
                          style: GoogleFonts.outfit(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.edit, color: Colors.white),
                  ),
                ],
              ),
            ),

            // General Section
            _buildSectionHeader('General'),
            _buildSettingTile(
              context,
              icon: Icons.category_outlined,
              title: 'Manage Categories',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Category Manager Coming Soon!'),
                  ),
                );
              },
            ),
            _buildSettingTile(
              context,
              icon: Icons.file_download_outlined,
              title: 'Export Data (CSV/PDF)',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => ExportService.exportToCSV(context),
            ),
            _buildSettingTile(
              context,
              icon: Icons.currency_exchange,
              title: 'Currency',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'USD (\$)',
                    style: GoogleFonts.outfit(color: Colors.grey),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Currency Settings Coming Soon!'),
                  ),
                );
              },
            ),

            // Preferences Section
            _buildSectionHeader('Preferences'),
            _buildSettingTile(
              context,
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              trailing: Switch(
                value: true,
                onChanged: (val) {},
                activeColor: AppTheme.primaryColor,
              ),
            ),
            _buildSettingTile(
              context,
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
              trailing: Switch(
                value: isDark,
                onChanged: (val) {
                  themeProvider.toggleTheme(val);
                },
                activeColor: AppTheme.primaryColor,
              ),
            ),

            // Support Section
            _buildSectionHeader('Support'),
            _buildSettingTile(
              context,
              icon: Icons.help_outline,
              title: 'Help & Support',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
            _buildSettingTile(
              context,
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),

            const SizedBox(height: 24),
            // Logout
            TextButton(
              onPressed: () {},
              child: Text(
                'Log Out',
                style: GoogleFonts.outfit(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Theme.of(context).primaryColor),
      ),
      title: Text(
        title,
        style: GoogleFonts.outfit(fontWeight: FontWeight.w500),
      ),
      trailing: trailing,
    );
  }
}
