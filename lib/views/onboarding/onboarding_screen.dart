import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Track your expenses',
      'subtitle': 'Quickly add income and expenses with intuitive controls',
    },
    {
      'title': 'Visualize spending',
      'subtitle': 'See category breakdowns and trends over time',
    },
    {
      'title': 'Secure & private',
      'subtitle': 'Biometric auth and local encrypted backups',
    },
  ];

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, index) {
                  final p = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.account_balance_wallet, size: 96, color: Theme.of(context).primaryColor),
                        const SizedBox(height: 24),
                        Text(p['title']!, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Text(p['subtitle']!, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () async => await _finishOnboarding(),
                    child: const Text('Skip'),
                  ),
                  const Spacer(),
                  Row(
                    children: List.generate(_pages.length, (i) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _index == i ? 12 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _index == i ? Theme.of(context).primaryColor : Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    )),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (_index < _pages.length - 1) {
                        _controller.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
                      } else {
                        _finishOnboarding();
                      }
                    },
                    child: Text(_index < _pages.length - 1 ? 'Next' : 'Get started'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
