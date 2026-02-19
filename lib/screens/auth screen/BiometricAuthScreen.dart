import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled/services/biometric_service.dart';

import '../../utils/theme.dart';
import '../main_wrapper.dart';
import '../splash screen/splash_screen.dart';

class BiometricAuthScreen extends StatefulWidget {
  const BiometricAuthScreen({super.key});

  @override
  State<BiometricAuthScreen> createState() => _BiometricAuthScreenState();
}

class _BiometricAuthScreenState extends State<BiometricAuthScreen> {
  final String TAG = 'biometric screen';
  bool _isLoading = true;
  bool _isAuthenticated = false;
  String _errorMsg = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkBiometricSupport());
  }

  Future<void> _checkBiometricSupport() async {
    setState(() {
      _isLoading = true;
      _errorMsg = '';
    });

    final isSupported = await BiometricService.isDeviceSupported();

    if (!isSupported) {
      setState(() {
        _isLoading = false;
        _errorMsg = 'Biometric authentication is not supported on this device';
      });
      return;
    }

    _authenticate();
  }

  Future<void> _authenticate() async {
    print('$TAG : Started auth');
    final authenticated = await BiometricService.authenticate();

    if (authenticated && mounted) {
      setState(() {
        _isAuthenticated = true;
        _isLoading = false;
      });
      print('$TAG : isAuthed: $_isAuthenticated');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const  MainWrapper(),
        ),
      );
      print('$TAG navigated');
    } else if (mounted) {
      setState(() {
        _isLoading = false;
        _errorMsg = 'Authentication failed. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF121212) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.fingerprint,
                  size: 60,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 40),

              Text(
                'Biometric Authentication',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),

              // Subtitle
              Text(
                'Secure your financial data with biometric lock',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: textColor.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 40),

              if (_isLoading)
                Column(
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Checking biometric...',
                      style: GoogleFonts.outfit(color: textColor),
                    ),
                  ],
                )
              else if (_errorMsg.isNotEmpty)
                Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMsg,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        color: Colors.red.shade300,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _checkBiometricSupport,
                          label: const Text('Try again'),
                          icon: const Icon(Icons.refresh),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        TextButton(
                          onPressed: () {
                            // Skip authentication (optional)
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (ctx) => const SplashScreen(
                                  nextScreen: MainWrapper(),
                                ),
                              ),
                            );
                          },
                          child: const Text('Skip'),
                        ),
                      ],
                    ),
                  ],
                )
              else
              ElevatedButton.icon(
                onPressed: _authenticate,
                icon: const Icon(Icons.fingerprint),
                label: const Text('Authenticate'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
