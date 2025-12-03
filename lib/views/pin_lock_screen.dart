import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

enum PinMode { setPin, unlock, changePin }

class PinLockScreen extends ConsumerStatefulWidget {
  final PinMode mode;
  const PinLockScreen({super.key, required this.mode});

  @override
  ConsumerState<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends ConsumerState<PinLockScreen> {
  final TextEditingController _currentPin = TextEditingController();
  final TextEditingController _newPin = TextEditingController();
  final TextEditingController _confirmPin = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _currentPin.dispose();
    _newPin.dispose();
    _confirmPin.dispose();
    super.dispose();
  }

  void _onSubmit() async {
    final auth = ref.read(authProvider.notifier);
    switch (widget.mode) {
      case PinMode.unlock:
        final ok = auth.verifyPin(_currentPin.text);
        if (ok) {
          Navigator.pop(context, true);
        } else {
          setState(() => _error = 'Incorrect PIN');
        }
        break;
      case PinMode.setPin:
        if (_newPin.text.length < 4 || _newPin.text != _confirmPin.text) {
          setState(() => _error = 'PIN must match and be 4+ digits');
          return;
        }
        await auth.setPin(_newPin.text);
        if (mounted) Navigator.pop(context, true);
        break;
      case PinMode.changePin:
        if (_newPin.text.length < 4 || _newPin.text != _confirmPin.text) {
          setState(() => _error = 'PIN must match and be 4+ digits');
          return;
        }
        final ok = await auth.changePin(
            currentPin: _currentPin.text, newPin: _newPin.text);
        if (ok) {
          if (mounted) Navigator.pop(context, true);
        } else {
          setState(() => _error = 'Current PIN incorrect');
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUnlock = widget.mode == PinMode.unlock;
    return PopScope(
      canPop: !isUnlock, // Block back if unlock mode
      child: Scaffold(
        appBar: isUnlock
            ? null
            : AppBar(
                title: Text(widget.mode == PinMode.setPin
                    ? 'Set PIN'
                    : widget.mode == PinMode.changePin
                        ? 'Change PIN'
                        : 'Unlock'),
              ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.indigo.withOpacity(0.25),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.indigo,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.lock,
                                color: Colors.white, size: 36),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            isUnlock
                                ? 'Enter PIN to Continue'
                                : (widget.mode == PinMode.setPin
                                    ? 'Create Secure PIN'
                                    : 'Update Your PIN'),
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isUnlock
                                ? 'For your security, please unlock access.'
                                : 'Use at least 4 digits you can remember.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_error != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error,
                                color: Colors.red.shade700, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _error!,
                                style: TextStyle(color: Colors.red.shade700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (widget.mode != PinMode.setPin)
                      TextField(
                        controller: _currentPin,
                        decoration: const InputDecoration(
                          labelText: 'PIN',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                      ),
                    if (widget.mode != PinMode.unlock) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: _newPin,
                        decoration: const InputDecoration(
                          labelText: 'New PIN',
                          prefixIcon: Icon(Icons.lock),
                        ),
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _confirmPin,
                        decoration: const InputDecoration(
                          labelText: 'Confirm PIN',
                          prefixIcon: Icon(Icons.lock),
                        ),
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _onSubmit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          isUnlock ? 'UNLOCK' : 'SAVE PIN',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
