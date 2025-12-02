import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dashboard_components.dart';
import 'transactions_screen.dart';
import 'enhanced_reports_screen.dart';
import 'enhanced_settings_screen.dart';
import 'add_transaction_modal.dart';
import '../providers/auth_provider.dart';
import 'pin_lock_screen.dart';
import 'recurring_transactions_screen.dart';
import 'category_management_screen.dart';
import 'budget_goals_screen.dart';

class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  int _currentIndex = 0;
  late PageController _pageController;
  DateTime? _backgroundEnteredAt;
  static const Duration _lockThreshold = Duration(seconds: 20); // Lock only after 20s background
  bool _lockPresented = false;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const TransactionsScreen(),
    const EnhancedReportsScreen(),
    const EnhancedSettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addObserver(this);
    // If app launches in locked state, present PIN immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = ref.read(authProvider);
      if (auth.hasPin && auth.locked && !_lockPresented && mounted) {
        _lockPresented = true;
        Navigator.of(context, rootNavigator: true)
            .push(
              MaterialPageRoute(
                fullscreenDialog: true,
                builder: (_) => const PinLockScreen(mode: PinMode.unlock),
              ),
            )
            .whenComplete(() {
          if (mounted) setState(() => _lockPresented = false);
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _backgroundEnteredAt = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      final auth = ref.read(authProvider);
      if (auth.hasPin) {
        final elapsed = _backgroundEnteredAt == null
            ? Duration.zero
            : DateTime.now().difference(_backgroundEnteredAt!);
        if (elapsed >= _lockThreshold) {
          // Only lock if threshold exceeded
          ref.read(authProvider.notifier).lock();
        }
        if (ref.read(authProvider).locked && !_lockPresented) {
          _lockPresented = true;
          if (!mounted) return;
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                fullscreenDialog: true,
                builder: (_) => const PinLockScreen(mode: PinMode.unlock),
              ),
            );
            // When returning, allow future locks to present again
            if (mounted) setState(() => _lockPresented = false);
          });
        } else if (!ref.read(authProvider).locked) {
          _lockPresented = false;
        }
      }
    }
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
  }

  void _onTabTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics:
            const NeverScrollableScrollPhysics(), // Disable swipe to prevent accidental navigation
        children: _screens,
      ),
      floatingActionButton: _currentIndex == 0 || _currentIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () => _showGlobalAddSheet(context),
              icon: const Icon(Icons.add),
              label: const Text('Add'),
              elevation: 8,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        elevation: 8,
        color: cs.surface,
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(Icons.dashboard, 'Home', 0),
              _buildNavItem(Icons.list_alt, 'Transactions', 1),
              const SizedBox(width: 48), // Space for FAB
              _buildNavItem(Icons.bar_chart, 'Reports', 2),
              _buildNavItem(Icons.settings, 'Settings', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    final cs = Theme.of(context).colorScheme;
    final navInk = InkWell(
        onTap: () {
          if (index == 1) {
            // Use Transaction nav item as quick add action matching dashboard style.
            showAddTransactionModal(context);
            return; // Do not change page index
          }
          _onTabTapped(index);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isSelected ? cs.primary.withOpacity(0.15) : Colors.transparent,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? cs.primary : cs.onSurfaceVariant,
                size: 22,
              ),
              const SizedBox(height: 2),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: isSelected ? cs.primary : cs.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );

    return Expanded(
      child: index == 1
          ? Tooltip(
              message: 'Quick Add',
              waitDuration: const Duration(milliseconds: 500),
              child: navInk,
            )
          : navInk,
    );
  }

  void _showGlobalAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.onSurface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Quick Add',
                style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildAddOption(
                    ctx,
                    icon: Icons.add_circle_outline,
                    label: 'Transaction',
                    color: cs.primary,
                    onTap: () {
                      Navigator.pop(ctx);
                      showAddTransactionModal(context);
                    },
                  ),
                  _buildAddOption(
                    ctx,
                    icon: Icons.repeat,
                    label: 'Recurring',
                    color: Colors.purple,
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RecurringTransactionsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildAddOption(
                    ctx,
                    icon: Icons.category,
                    label: 'Category',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CategoryManagementScreen(),
                        ),
                      );
                    },
                  ),
                  _buildAddOption(
                    ctx,
                    icon: Icons.flag,
                    label: 'Budget Goal',
                    color: Colors.teal,
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BudgetGoalsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddOption(BuildContext context,
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // unified add transaction modal provided by add_transaction_modal.dart
}
