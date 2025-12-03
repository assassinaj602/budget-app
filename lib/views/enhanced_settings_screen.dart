import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider_riverpod.dart';
import '../providers/currency_provider.dart';
import '../providers/app_provider.dart';
import '../utils/currencies.dart';
import 'pin_lock_screen.dart';
import 'currency_selector_screen.dart';
import 'budget_goals_screen.dart';
import 'category_management_screen.dart';
import 'recurring_transactions_screen.dart';
import '../services/advanced_export_service.dart';
import '../services/notification_service.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

class EnhancedSettingsScreen extends ConsumerStatefulWidget {
  const EnhancedSettingsScreen({super.key});

  @override
  ConsumerState<EnhancedSettingsScreen> createState() =>
      _EnhancedSettingsScreenState();
}

class _EnhancedSettingsScreenState
    extends ConsumerState<EnhancedSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _autoBackup = false;
  String _selectedLanguage = 'English';
  Box? _settingsBox;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _settingsBox = await Hive.openBox('settings');
    setState(() {
      _notificationsEnabled =
          _settingsBox!.get('notificationsEnabled', defaultValue: true);
      _autoBackup = _settingsBox!.get('autoBackup', defaultValue: false);
      _selectedLanguage =
          _settingsBox!.get('language', defaultValue: 'English');
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    await _settingsBox?.put(key, value);
  }

  // Biometric toggle is centralized in authProvider; no local handler needed.

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
                  leading: const Icon(Icons.repeat),
                  title: const Text('Recurring Transactions'),
                  subtitle:
                      const Text('Manage subscriptions and regular payments'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const RecurringTransactionsScreen(),
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
                // Biometric authentication removed per requirements.
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text('Change PIN'),
                  subtitle: const Text('Update your app access PIN'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () async {
                    // Navigate to PIN change flow
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const PinLockScreen(mode: PinMode.changePin),
                      ),
                    );
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
                      setState(() => _autoBackup = value);
                      _saveSetting('autoBackup', value);
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
                      setState(() => _notificationsEnabled = value);
                      _saveSetting('notificationsEnabled', value);
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
                  onTap: () async {
                    const repoUrl =
                        'https://github.com/assassinaj602/budget-app';
                    await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Share App'),
                        content: SelectableText(repoUrl),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close')),
                          TextButton(
                            onPressed: () async {
                              await Clipboard.setData(
                                  const ClipboardData(text: repoUrl));
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Link copied to clipboard')));
                            },
                            child: const Text('Copy Link'),
                          ),
                        ],
                      ),
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
                  _selectedLanguage = 'English';
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Save language after dialog closes
  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    // Persist language when it changes (debounced minimal logic)
    if (_settingsBox != null) {
      _saveSetting('language', _selectedLanguage);
    }
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
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete category'),
                        content: Text(
                            'Delete category "${category.name}"? This will remove it from your local data.'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel')),
                          TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Delete')),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      try {
                        await ref
                            .read(appProvider.notifier)
                            .deleteCategory(category.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Category "${category.name}" deleted')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Failed to delete category: $e')),
                        );
                      }
                    }
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
            onPressed: () async {
              Navigator.pop(context);
              final current = ref.read(appProvider);
              try {
                await AdvancedExportService.exportTransactionsToCSV(
                    current.transactions, current.categories);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data exported as CSV')));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('CSV export failed: $e')));
              }
            },
            child: const Text('CSV'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final current = ref.read(appProvider);
              try {
                await AdvancedExportService.createFullBackup(
                    current.transactions, current.categories, {});
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data exported as JSON')));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('JSON export failed: $e')));
              }
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
            onPressed: () async {
              Navigator.pop(context);
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirm Clear All'),
                  content: const Text(
                      'This will attempt to clear local data (transactions & categories). This cannot be undone.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel')),
                    TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Clear')),
                  ],
                ),
              );
              if (confirmed == true) {
                try {
                  // Attempt to clear Hive boxes if available
                  if (Hive.isBoxOpen('transactions')) {
                    await Hive.box('transactions').clear();
                  }
                  if (Hive.isBoxOpen('categories')) {
                    await Hive.box('categories').clear();
                  }
                  // Reset in-memory state
                  await ref.read(appProvider.notifier).clearAllData();
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Local data cleared')));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to clear data: $e')));
                }
              }
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
                  if (value) {
                    NotificationService()
                        .scheduleDailySummary(hour: 18, minute: 0);
                  } else {
                    NotificationService().cancelAllNotifications();
                  }
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
                    NotificationService().scheduleDailySummary(
                        hour: time.hour, minute: time.minute);
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
            // Cloud sync removed for offline-only operation.
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
                    {},
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
              onTap: () async {
                await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('PDF Report'),
                    content: const Text(
                        'PDF export will be available in a future update. For now, export JSON/CSV and use external tools to create reports.'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close')),
                    ],
                  ),
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
              onPressed: () async {
                // In a real app, you'd use file_picker package. For now, show guidance.
                Navigator.pop(context);
                await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Import Data'),
                    content: const Text(
                        'To import data, prepare a CSV or JSON export and place it in your device storage. File import will be added in a future update.'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close')),
                    ],
                  ),
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
