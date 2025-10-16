import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();
  static const String _biometricEnabledKey = 'biometric_enabled';

  /// Check if biometric authentication is available on the device
  Future<bool> isBiometricAvailable() async {
    try {
      return await _auth.canCheckBiometrics && await _auth.isDeviceSupported();
    } on PlatformException catch (e) {
      print('Biometric check error: $e');
      return false;
    }
  }

  /// Get available biometric types (fingerprint, face, etc.)
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print('Get biometrics error: $e');
      return [];
    }
  }

  /// Authenticate using biometrics
  Future<bool> authenticate() async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) return false;

      return await _auth.authenticate(
        localizedReason: 'Please authenticate to access your budget data',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } on PlatformException catch (e) {
      print('Authentication error: $e');
      return false;
    }
  }

  /// Check if biometric is enabled in settings
  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricEnabledKey) ?? false;
  }

  /// Enable or disable biometric authentication
  Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, enabled);
  }

  /// Get biometric type name for display
  String getBiometricTypeName(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return 'Face ID';
      case BiometricType.fingerprint:
        return 'Fingerprint';
      case BiometricType.iris:
        return 'Iris';
      case BiometricType.strong:
        return 'Strong Biometric';
      case BiometricType.weak:
        return 'Weak Biometric';
    }
  }
}
