import 'package:flutter/material.dart';
import 'dart:ui';
import 'main_navigation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'pin_lock_screen.dart';

class SplashScreen extends StatefulWidget {
  final bool seenOnboarding;

  const SplashScreen({super.key, required this.seenOnboarding});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        if (!widget.seenOnboarding) {
          Navigator.of(context).pushReplacementNamed('/onboarding');
          return;
        }
        // After onboarding, gate by PIN if set
        final container = ProviderScope.containerOf(context, listen: false);
        final auth = container.read(authProvider);
        if (auth.hasPin && auth.locked) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (_) => const PinLockScreen(mode: PinMode.unlock)),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainNavigation()),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final gradientColors = [
      cs.primary,
      cs.primary.withOpacity(0.85),
    ];
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Glassmorphism Card with Icon and App Name
              Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) => Opacity(
                    opacity: _fadeAnim.value,
                    child: Transform.scale(
                      scale: _scaleAnim.value,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                          child: Container(
                            width: 230,
                            padding: const EdgeInsets.symmetric(
                                vertical: 40, horizontal: 24),
                            decoration: BoxDecoration(
                              color: cs.surface.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(
                                  color: cs.onSurface.withOpacity(0.12),
                                  width: 1.2),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 24,
                                  spreadRadius: 2,
                                )
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Animated wallet icon
                                    AnimatedBuilder(
                                      animation: _controller,
                                      builder: (context, child) {
                                        return Transform.rotate(
                                          angle: _scaleAnim.value * 2 * 3.1416,
                                          child: Icon(
                                            Icons
                                                .account_balance_wallet_rounded,
                                            size: 72,
                                            color: Colors.white,
                                            shadows: [
                                              Shadow(
                                                color: Colors.indigo
                                                    .withOpacity(0.18),
                                                blurRadius: 8,
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                    // Animated pie chart icon overlay
                                    AnimatedBuilder(
                                      animation: _controller,
                                      builder: (context, child) {
                                        return Opacity(
                                          opacity: _fadeAnim.value,
                                          child: Transform.scale(
                                            scale: 0.7 + 0.3 * _scaleAnim.value,
                                            child: Icon(
                                              Icons.pie_chart_rounded,
                                              size: 38,
                                              color: cs.secondary,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                AnimatedBuilder(
                                  animation: _controller,
                                  builder: (context, child) => Opacity(
                                    opacity: _fadeAnim.value,
                                    child: Text(
                                      'Budget App',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 28,
                                        color: cs.onPrimary
                                            .withOpacity(_fadeAnim.value),
                                        letterSpacing: 1.1,
                                        shadows: [
                                          Shadow(
                                            color:
                                                cs.onPrimary.withOpacity(0.25),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
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
                ),
              ),
              // Developer Credit
              Positioned(
                left: 0,
                right: 0,
                bottom: 32,
                child: Column(
                  children: [
                    Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 80, vertical: 8),
                      color: cs.onPrimary.withOpacity(0.18),
                    ),
                    Text(
                      'Developed By Muhammad Assad Ullah',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: cs.onPrimary.withOpacity(0.85),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        letterSpacing: 0.4,
                        shadows: [
                          Shadow(
                            color: cs.onPrimary.withOpacity(0.12),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
