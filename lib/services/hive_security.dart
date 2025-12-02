import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

class HiveSecurity {
  static const _keyName = 'hive_key_v1';
  static final _storage = const FlutterSecureStorage();

  static Future<HiveAesCipher?> getCipher() async {
    try {
      String? base64Key = await _storage.read(key: _keyName);
      if (base64Key == null) {
        final key = _generateSecureKey();
        base64Key = base64Encode(key);
        await _storage.write(key: _keyName, value: base64Key);
      }
      final keyBytes = base64Decode(base64Key);
      if (keyBytes.length != 32) return null; // invalid key length
      return HiveAesCipher(keyBytes);
    } catch (e) {
      if (kDebugMode) {
        print('HiveSecurity.getCipher error: $e');
      }
      return null; // Fallback to no encryption if secure storage fails
    }
  }

  static List<int> _generateSecureKey() {
    final rng = Random.secure();
    return List<int>.generate(32, (_) => rng.nextInt(256));
  }
}
