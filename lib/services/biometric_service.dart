import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();
  static final String TAG = 'Biometric Debug';

  static Future<bool> isDeviceSupported() async {
    try {
      final isSupported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      final availableBiometrics = await _auth.getAvailableBiometrics();

      print('=== ${TAG} ===');
      print('isSupported: $isSupported');
      print('canCheck: $canCheck');
      print('availableBiometrics: $availableBiometrics');
      print('=======================');

      return isSupported && canCheck;
    } on PlatformException catch (_) {
      return false;
    }
  }

  static Future<bool> authenticate() async {
    try {
      final isSupported = await isDeviceSupported();
      if(!isSupported){
        print('${TAG} : Device does not support biometrics');
        return false;
      }
      print('${TAG}: isSupported : ${isSupported}');

      final authenticated = await _auth.authenticate(
        localizedReason: 'Please authenticate to access your finances',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
          useErrorDialogs: true
        ),
      );

      print('${TAG} : Auth result : $authenticated');
      return authenticated;
    } on PlatformException catch (_) {
      return false;
    }
  }
}
