import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/theme_provider_riverpod.dart';
import '../providers/currency_provider.dart';
import '../utils/currencies.dart';
import 'currency_selector_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: ref.watch(themeProvider) == ThemeMode.dark,
              onChanged: (_) => ref.read(themeProvider.notifier).toggleTheme(),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('Currency'),
            subtitle: Text(getCurrencyName(ref.watch(currencyProvider))),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  ref.watch(currencyProvider),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CurrencySelectorScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: Card(
              color: const Color(0xFFE8EAF6),
              elevation: 3,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16))),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.account_circle,
                        size: 48, color: Color(0xFF5C6BC0)),
                    const SizedBox(height: 12),
                    const Text('About the Developer',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.indigo)),
                    const SizedBox(height: 16),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person, color: Colors.indigo, size: 20),
                        SizedBox(width: 8),
                        Text('Developed by: ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo)),
                        Flexible(
                            child: Text('Muhammad Assad Ullah',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.indigo))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.email, color: Colors.indigo, size: 20),
                        SizedBox(width: 8),
                        Text('Email: ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo)),
                        Flexible(
                            child: Text('asadullahaj602@gmail.com',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.indigo))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.link, color: Colors.indigo, size: 20),
                        const SizedBox(width: 8),
                        const Text('LinkedIn: ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo)),
                        Flexible(
                          child: InkWell(
                            child: const Text(
                              'www.linkedin.com/in/muhammad-assadullah',
                              style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.w500),
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                            onTap: () async {
                              final url = Uri.parse(
                                  'https://www.linkedin.com/in/muhammad-assadullah');
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url,
                                    mode: LaunchMode.externalApplication);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
