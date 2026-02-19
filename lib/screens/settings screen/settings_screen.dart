import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:untitled/providers/theme_provider.dart';
import 'package:untitled/screens/settings%20screen/CurencyType.dart';
import 'package:untitled/services/export_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/services/pdf/Final_pdf_service.dart';
import 'package:untitled/services/biometric_service.dart';
import 'package:untitled/providers/expense_provider.dart';
import 'package:untitled/utils/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  CurrencyType _selectedCurrency = CurrencyType.BDT;
  bool _isBiometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricStatus(); // //english comment: load initial value once
  }

  Future<void> _loadBiometricStatus() async {
    final status = await _getBiometricStatus();
    setState(() {
      _isBiometricEnabled = status;
    });
  }

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
              title: 'Export Data (PDF)',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                final transactions = Provider.of<ExpenseProvider>(
                  context,
                  listen: false,
                ).transactions;
                await FinalPdfService.generateTransactionReport(transactions);
              },
            ),

            _buildSettingTile(
              context,
              icon: Icons.share,
              title: 'Share Data (PDF)',
              trailing: const Icon(Icons.ios_share_outlined, size: 16),
              onTap: () async {
                final transactions = Provider.of<ExpenseProvider>(
                  context,
                  listen: false,
                ).transactions;
                await FinalPdfService.shareTransactionReport(transactions);
              },
            ),

            _buildSettingTile(
              context,
              icon: Icons.currency_exchange,
              title: 'Currency',
              trailing: PopupMenuButton<CurrencyType>(
                onSelected: (currency) {
                  setState(() {
                    _selectedCurrency = currency;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Currency changed to ${currency.name}'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                itemBuilder: (context) => [
                  ...CurrencyType.values.map((currency) {
                    return PopupMenuItem(
                      value: currency,
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            child: Text(
                              currency.symbol,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          const SizedBox(width: 8),

                          Expanded(
                            child: Text(
                              currency.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          if (_selectedCurrency == currency)
                            const Icon(
                              Icons.check,
                              color: Colors.green,
                              size: 16,
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_selectedCurrency.symbol} ${_selectedCurrency.name}',
                        style: GoogleFonts.outfit(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white70
                              : Colors.grey[700],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_drop_down,
                        size: 20,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : Colors.grey[700],
                      ),
                    ],
                  ),
                ),
              ),
              onTap: () {},
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

            // Biometric Lock
            // SettingsScreen এ Biometric Switch অংশ
            _buildSettingTile(
              context,
              icon: Icons.fingerprint,
              title: 'Biometric Security',
              trailing: Switch(
                value: _isBiometricEnabled,
                onChanged: (val) {
                  if (val) {
                    // অন করার সময় authenticate করতে হবে
                    _setBiometricStatus(true);
                    _showRestartDialog(context);
                  }
                  else {
                    _setBiometricStatus(false);
                  }
                  setState(() {
                    _isBiometricEnabled= !_isBiometricEnabled;
                  });
                  },
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

  Future<bool> _getBiometricStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('biometric_enabled') ?? false;
  }

  Future<void> _setBiometricStatus(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', enabled);
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

  void _showRestartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restart Required'),
        content: const Text(
          'Biometric security has been enabled. Please restart the app for the changes to take effect.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
