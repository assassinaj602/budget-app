import 'dart:convert';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';

class AuthState {
  final bool hasPin;
  final bool locked;
  const AuthState({required this.hasPin, required this.locked});
  AuthState copyWith({bool? hasPin, bool? locked}) =>
      AuthState(
        hasPin: hasPin ?? this.hasPin,
        locked: locked ?? this.locked,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState(hasPin: false, locked: false)) {
    _init();
  }

  Box? _authBox;
  final FlutterSecureStorage _secure = const FlutterSecureStorage();

  Future<void> _init() async {
    _authBox = await Hive.openBox('auth');
    final pinHash = await _secure.read(key: 'pinHash');
    final pinSalt = await _secure.read(key: 'pinSalt');
    if (pinHash != null) {
      await _authBox?.put('pinHash', pinHash);
    }
    if (pinSalt != null) {
      await _authBox?.put('pinSalt', pinSalt);
    }
    state = state.copyWith(hasPin: pinHash != null, locked: pinHash != null);
  }

  Future<void> setPin(String pin) async {
    final salt = _randomSalt(16);
    final hash = _hashPin(pin, salt);
    await _secure.write(key: 'pinSalt', value: base64Encode(salt));
    await _secure.write(key: 'pinHash', value: base64Encode(hash));
    await _authBox?.put('pinSalt', base64Encode(salt));
    await _authBox?.put('pinHash', base64Encode(hash));
    state = state.copyWith(hasPin: true, locked: true);
  }

  bool verifyPin(String pin) {
    final savedSaltB64 = _syncRead('pinSalt');
    final savedHashB64 = _syncRead('pinHash');
    if (savedSaltB64 == null || savedHashB64 == null) return false;
    final salt = base64Decode(savedSaltB64);
    final expected = base64Decode(savedHashB64);
    final computed = _hashPin(pin, salt);
    final ok = _timingSafeEquals(expected, computed);
    if (ok) state = state.copyWith(locked: false);
    return ok;
  }

  Future<bool> changePin({required String currentPin, required String newPin}) async {
    if (!state.hasPin) {
      await setPin(newPin);
      return true;
    }
    if (verifyPin(currentPin)) {
      final salt = _randomSalt(16);
      final hash = _hashPin(newPin, salt);
      await _secure.write(key: 'pinSalt', value: base64Encode(salt));
      await _secure.write(key: 'pinHash', value: base64Encode(hash));
      await _authBox?.put('pinSalt', base64Encode(salt));
      await _authBox?.put('pinHash', base64Encode(hash));
      state = state.copyWith(hasPin: true);
      return true;
    }
    return false;
  }

  // Biometric functionality removed per requirements.

  void lock() {
    if (state.hasPin) {
      state = state.copyWith(locked: true);
    }
  }

  // Helpers
  List<int> _randomSalt(int length) {
    final rnd = Random.secure();
    return List<int>.generate(length, (_) => rnd.nextInt(256));
  }

  List<int> _hashPin(String pin, List<int> salt) {
    final bytes = <int>[]..addAll(utf8.encode(pin))..addAll(salt);
    final digest = sha256.convert(bytes);
    return digest.bytes;
  }

  bool _timingSafeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    int diff = 0;
    for (int i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }

  String? _syncRead(String key) {
    // flutter_secure_storage is async; for verify we need sync-like behavior.
    // This method should not be used in production for heavy calls.
    // Here we just throw to ensure it's not called accidentally in UI thread.
    // Instead, we read cached values via Hive? To keep simple, we block via Future.value().
    // But Dart doesn't allow sync wait; so we keep previously stored values in Hive mirror.
    // Fallback to Hive mirror keys if present.
    return _authBox?.get(key);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());
