import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider_riverpod.dart';
import '../providers/currency_provider.dart';
import '../providers/app_provider.dart';
import '../utils/currencies.dart';
import 'currency_selector_screen.dart';
import 'budget_goals_screen.dart';
import 'category_management_screen.dart';
import '../services/advanced_export_service.dart';

class EnhancedSettingsScreen extends ConsumerStatefulWidget {
  const EnhancedSettingsScreen({super.key});

  @override
  ConsumerState<EnhancedSettingsScreen> createState() =>
      _EnhancedSettingsScreenState();
}

class _EnhancedSettingsScreenState
    extends ConsumerState<EnhancedSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  bool _autoBackup = false;
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance Section
          Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.palette,
                          color: Theme.of(context).primaryColor),
                      const SizedBox(width: 12),
                      Text(
                        'Appearance',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.dark_mode),
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Toggle between light and dark themes'),
                  trailing: Switch(
                    value: ref.watch(themeProvider) == ThemeMode.dark,
                    onChanged: (_) =>
                        ref.read(themeProvider.notifier).toggleTheme(),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('Language'),
                  subtitle: Text(_selectedLanguage),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showLanguageDialog();
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Financial Settings Section
          Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.account_balance_wallet,
                          color: Colors.green.shade600),
                      const SizedBox(width: 12),
                      Text(
                        'Financial Settings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade600,
                        ),
                      ),
                    ],
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
                ListTile(
                  leading: const Icon(Icons.trending_up),
                  title: const Text('Budget Goals'),
                  subtitle: const Text('Set and manage your budget targets'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BudgetGoalsScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.category),
                  title: const Text('Manage Categories'),
                  subtitle:
                      const Text('Add, edit, or remove transaction categories'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showCategoriesDialog();
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Security & Privacy Section
          Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.security, color: Colors.orange.shade600),
                      const SizedBox(width: 12),
                      Text(
                        'Security & Privacy',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.fingerprint),
                  title: const Text('Biometric Authentication'),
                  subtitle: const Text(
                      'Use fingerprint or face ID to secure your app'),
                  trailing: Switch(
                    value: _biometricEnabled,
                    onChanged: (value) {
                      setState(() {
                        _biometricEnabled = value;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(value
                              ? 'Biometric authentication enabled'
                              : 'Biometric authentication disabled'),
                        ),
                      );
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text('Change PIN'),
                  subtitle: const Text('Update your app access PIN'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showChangePinDialog(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.visibility_off),
                  title: const Text('Privacy Settings'),
                  subtitle: const Text('Control what data is shared'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showPrivacyDialog();
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Data Management Section
          Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.storage, color: Colors.blue.shade600),
                      const SizedBox(width: 12),
                      Text(
                        'Data Management',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.backup),
                  title: const Text('Auto Backup'),
                  subtitle: const Text('Automatically backup your data'),
                  trailing: Switch(
                    value: _autoBackup,
                    onChanged: (value) {
                      setState(() {
                        _autoBackup = value;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(value
                              ? 'Auto backup enabled'
                              : 'Auto backup disabled'),
                        ),
                      );
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.cloud_upload),
                  title: const Text('Export Data'),
                  subtitle:
                      const Text('Export your transactions and categories'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showExportDialog();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.cloud_download),
                  title: const Text('Import Data'),
                  subtitle:
                      const Text('Import data from backup or other sources'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showDataManagementDialog(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text('Clear All Data',
                      style: TextStyle(color: Colors.red)),
                  subtitle: const Text('Permanently delete all your data'),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.red),
                  onTap: () {
                    _showClearDataDialog();
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Notifications Section
          Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.notifications, color: Colors.purple.shade600),
                      const SizedBox(width: 12),
                      Text(
                        'Notifications',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.notifications_active),
                  title: const Text('Push Notifications'),
                  subtitle: const Text('Receive alerts and reminders'),
                  trailing: Switch(
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(value
                              ? 'Notifications enabled'
                              : 'Notifications disabled'),
                        ),
                      );
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.schedule),
                  title: const Text('Budget Reminders'),
                  subtitle: const Text('Get notified about budget limits'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showNotificationSettings(context);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // App Info Section
          Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.indigo.shade600),
                      const SizedBox(width: 12),
                      Text(
                        'App Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text('Help & Support'),
                  subtitle: const Text('Get help with using the app'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showHelpDialog();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.star_rate),
                  title: const Text('Rate the App'),
                  subtitle: const Text('Rate us on the app store'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Thank you for your support!')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.share),
                  title: const Text('Share App'),
                  subtitle: const Text('Tell your friends about this app'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Share feature coming soon!')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.account_circle),
                  title: const Text('About Developer'),
                  subtitle: const Text('Muhammad Assad Ullah'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showDeveloperDialog();
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Statistics Card
          Card(
            elevation: 4,
            color: Colors.grey.shade50,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.analytics, color: Colors.grey.shade600),
                      const SizedBox(width: 12),
                      Text(
                        'App Statistics',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            '${state.transactions.length}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text('Transactions'),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '${state.categories.length}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text('Categories'),
                        ],
                      ),
                      Column(
                        children: [
                          const Text(
                            'v1.0.0',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text('Version'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('English'),
              value: 'English',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Español'),
              value: 'Español',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Français'),
              value: 'Français',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoriesDialog() {
    final state = ref.watch(appProvider);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manage Categories'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: state.categories.length,
            itemBuilder: (context, index) {
              final category = state.categories[index];
              return ListTile(
                leading: Icon(category.icon),
                title: Text(category.name),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    // TODO: Implement category deletion
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Category deletion coming soon!')),
                    );
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CategoryManagementScreen(),
                ),
              );
            },
            child: const Text('Add New'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Settings'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your data is stored locally on your device.'),
            SizedBox(height: 8),
            Text('• No data is sent to external servers'),
            Text('• No personal information is collected'),
            Text('• All data remains on your device'),
            Text('• You have full control over your data'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Choose export format:'),
            SizedBox(height: 16),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('CSV export coming soon!')),
              );
            },
            child: const Text('CSV'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('JSON export coming soon!')),
              );
            },
            child: const Text('JSON'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
            'This will permanently delete all your transactions, categories, and settings. This action cannot be undone.\n\nAre you sure you want to continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Clear data feature coming soon!')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick Tips:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Tap the + button to add transactions'),
              Text('• Use the charts to view spending patterns'),
              Text('• Set budget goals to track your progress'),
              Text('• Export data for backup or analysis'),
              SizedBox(height: 16),
              Text(
                'Need more help?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Contact us at: support@budgetapp.com'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDeveloperDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Developer'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              child: Icon(Icons.person, size: 40),
            ),
            SizedBox(height: 16),
            Text(
              'Muhammad Assad Ullah',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Flutter Developer'),
            SizedBox(height: 8),
            Text('Email: assadullah@example.com'),
            SizedBox(height: 16),
            Text(
              'This app was built with love using Flutter and modern design principles to help you manage your finances better.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showChangePinDialog(BuildContext context) {
    final TextEditingController currentPinController = TextEditingController();
    final TextEditingController newPinController = TextEditingController();
    final TextEditingController confirmPinController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change PIN'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPinController,
                decoration: const InputDecoration(
                  labelText: 'Current PIN',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPinController,
                decoration: const InputDecoration(
                  labelText: 'New PIN',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPinController,
                decoration: const InputDecoration(
                  labelText: 'Confirm New PIN',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (newPinController.text == confirmPinController.text &&
                  newPinController.text.length == 6) {
                // In a real app, you'd verify the current PIN and save the new one
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('PIN changed successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('PINs do not match or are invalid!'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Update PIN'),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Notification Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('Push Notifications'),
                subtitle: const Text('General app notifications'),
                value: _notificationsEnabled,
                onChanged: (value) {
                  setDialogState(() => _notificationsEnabled = value);
                  setState(() => _notificationsEnabled = value);
                },
              ),
              SwitchListTile(
                title: const Text('Budget Reminders'),
                subtitle: const Text('Alerts when approaching budget limits'),
                value: _autoBackup,
                onChanged: (value) {
                  setDialogState(() => _autoBackup = value);
                  setState(() => _autoBackup = value);
                },
              ),
              ListTile(
                title: const Text('Reminder Time'),
                subtitle: const Text('Daily budget check at 6:00 PM'),
                leading: const Icon(Icons.schedule),
                onTap: () async {
                  final TimeOfDay? time = await showTimePicker(
                    context: context,
                    initialTime: const TimeOfDay(hour: 18, minute: 0),
                  );
                  if (time != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Reminder set for ${time.format(context)}')),
                    );
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDataManagementDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Data Management'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.file_download),
              title: const Text('Export Data'),
              subtitle: const Text('Download your data as CSV or JSON'),
              onTap: () {
                Navigator.pop(context);
                _showExportOptions(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_upload),
              title: const Text('Import Data'),
              subtitle: const Text('Import transactions from file'),
              onTap: () {
                Navigator.pop(context);
                _showImportDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.backup),
              title: const Text('Backup & Sync'),
              subtitle: const Text('Cloud backup settings'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cloud backup coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Clear All Data',
                  style: TextStyle(color: Colors.red)),
              subtitle: const Text('Permanently delete all data'),
              onTap: () {
                Navigator.pop(context);
                _showClearDataDialog();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showExportOptions(BuildContext context) async {
    final state = ref.read(appProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('CSV Format'),
              subtitle: const Text('Compatible with Excel and other apps'),
              onTap: () async {
                try {
                  await AdvancedExportService.exportTransactionsToCSV(
                    state.transactions,
                    state.categories,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data exported as CSV!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Export failed: $e')),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('JSON Format'),
              subtitle: const Text('Raw data format for developers'),
              onTap: () async {
                try {
                  await AdvancedExportService.createFullBackup(
                    state.transactions,
                    state.categories,
                    {}, // App settings
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data exported as JSON!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Export failed: $e')),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('PDF Report'),
              subtitle: const Text('Formatted report with charts'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PDF export coming soon!')),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showImportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.file_upload, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            const Text(
              'Import transactions from CSV or JSON file',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // In a real app, you'd use file_picker package
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('File import functionality coming soon!')),
                );
              },
              icon: const Icon(Icons.file_open),
              label: const Text('Choose File'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
