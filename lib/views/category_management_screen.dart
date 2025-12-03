import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_provider.dart';
import '../models/category.dart';
import '../views/theme/app_theme.dart';

class CategoryManagementScreen extends ConsumerStatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  ConsumerState<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState
    extends ConsumerState<CategoryManagementScreen> {
  final TextEditingController _nameController = TextEditingController();
  IconData _selectedIcon = Icons.category;
  Color _selectedColor = Colors.blue;

  final List<IconData> _availableIcons = [
    Icons.shopping_cart,
    Icons.restaurant,
    Icons.local_gas_station,
    Icons.home,
    Icons.medical_services,
    Icons.school,
    Icons.fitness_center,
    Icons.movie,
    Icons.travel_explore,
    Icons.pets,
    Icons.phone,
    Icons.electrical_services,
    Icons.cleaning_services,
    Icons.child_care,
    Icons.elderly,
    Icons.work,
    Icons.savings,
    Icons.credit_card,
    Icons.local_atm,
    Icons.business,
  ];

  final List<Color> _availableColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddCategoryDialog(),
            tooltip: 'Add Category',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Quick Stats
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Total Categories',
                      '${state.categories.length}',
                      Icons.category,
                      AppColors.primary,
                    ),
                  ),
                  Container(
                    height: 50,
                    width: 1,
                    color: Theme.of(context).dividerColor,
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Active This Month',
                      '${_getActiveCategories(state).length}',
                      Icons.trending_up,
                      AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Categories List
          if (state.categories.isNotEmpty) ...[
            Text(
              'Your Categories',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...state.categories
                .map((category) => _buildCategoryCard(category, state)),
          ] else ...[
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(Icons.category_outlined,
                        size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'No Categories Yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add your first category to start organizing expenses',
                      style: TextStyle(color: Colors.grey.shade500),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => _showAddCategoryDialog(),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Category'),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Suggested Categories
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb, color: AppColors.warning, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        'Suggested Categories',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _getSuggestedCategories(state)
                        .map(
                          (suggestion) => ActionChip(
                            avatar: Icon(suggestion['icon'], size: 18),
                            label: Text(suggestion['name']),
                            onPressed: () => _addSuggestedCategory(suggestion),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCategoryCard(Category category, AppState state) {
    final transactionCount =
        state.transactions.where((t) => t.category == category.name).length;

    final totalSpent = state.transactions
        .where((t) => t.category == category.name && t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(category.colorValue).withOpacity(0.18),
          child: Icon(
            category.icon,
            color: Color(category.colorValue),
          ),
        ),
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$transactionCount transactions',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
            Text('Total spent: ${totalSpent.toStringAsFixed(0)}',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleCategoryAction(value, category),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'duplicate',
              child: Row(
                children: [
                  Icon(Icons.copy, size: 20),
                  SizedBox(width: 8),
                  Text('Duplicate'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Category> _getActiveCategories(AppState state) {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month, 1);

    final activeCategoryNames = state.transactions
        .where((t) => t.date.isAfter(thisMonth))
        .map((t) => t.category)
        .toSet();

    return state.categories
        .where((c) => activeCategoryNames.contains(c.name))
        .toList();
  }

  List<Map<String, dynamic>> _getSuggestedCategories(AppState state) {
    final existingNames =
        state.categories.map((c) => c.name.toLowerCase()).toSet();

    final suggestions = [
      // Essential Living
      {'name': 'Groceries', 'icon': Icons.shopping_cart, 'color': Colors.green},
      {'name': 'Dining Out', 'icon': Icons.restaurant, 'color': Colors.orange},
      {
        'name': 'Transportation',
        'icon': Icons.directions_car,
        'color': Colors.blue
      },
      {
        'name': 'Gas & Fuel',
        'icon': Icons.local_gas_station,
        'color': Colors.red
      },
      {
        'name': 'Utilities',
        'icon': Icons.electrical_services,
        'color': Colors.amber
      },
      {'name': 'Rent/Mortgage', 'icon': Icons.home, 'color': Colors.brown},
      {'name': 'Phone & Internet', 'icon': Icons.phone, 'color': Colors.indigo},

      // Healthcare & Personal Care
      {
        'name': 'Healthcare',
        'icon': Icons.medical_services,
        'color': Colors.red
      },
      {'name': 'Pharmacy', 'icon': Icons.local_pharmacy, 'color': Colors.green},
      {'name': 'Dental Care', 'icon': Icons.healing, 'color': Colors.lightBlue},
      {'name': 'Personal Care', 'icon': Icons.face, 'color': Colors.pink},
      {
        'name': 'Haircut & Beauty',
        'icon': Icons.content_cut,
        'color': Colors.purple
      },

      // Entertainment & Lifestyle
      {'name': 'Entertainment', 'icon': Icons.movie, 'color': Colors.purple},
      {
        'name': 'Streaming Services',
        'icon': Icons.tv,
        'color': Colors.deepPurple
      },
      {'name': 'Movies & Theater', 'icon': Icons.theaters, 'color': Colors.red},
      {'name': 'Gaming', 'icon': Icons.sports_esports, 'color': Colors.blue},
      {'name': 'Books & Magazines', 'icon': Icons.book, 'color': Colors.brown},
      {'name': 'Music', 'icon': Icons.music_note, 'color': Colors.orange},

      // Shopping & Retail
      {'name': 'Clothing', 'icon': Icons.checkroom, 'color': Colors.pink},
      {'name': 'Electronics', 'icon': Icons.devices, 'color': Colors.blueGrey},
      {'name': 'Home & Garden', 'icon': Icons.grass, 'color': Colors.green},
      {'name': 'Furniture', 'icon': Icons.chair, 'color': Colors.brown},
      {
        'name': 'Online Shopping',
        'icon': Icons.shopping_bag,
        'color': Colors.deepOrange
      },

      // Health & Fitness
      {'name': 'Fitness', 'icon': Icons.fitness_center, 'color': Colors.teal},
      {
        'name': 'Gym Membership',
        'icon': Icons.sports_gymnastics,
        'color': Colors.red
      },
      {'name': 'Sports', 'icon': Icons.sports_soccer, 'color': Colors.green},
      {'name': 'Supplements', 'icon': Icons.medication, 'color': Colors.orange},

      // Education & Development
      {'name': 'Education', 'icon': Icons.school, 'color': Colors.indigo},
      {'name': 'Online Courses', 'icon': Icons.computer, 'color': Colors.blue},
      {
        'name': 'Training',
        'icon': Icons.model_training,
        'color': Colors.purple
      },
      {'name': 'Conferences', 'icon': Icons.event, 'color': Colors.teal},

      // Travel & Transportation
      {'name': 'Travel', 'icon': Icons.travel_explore, 'color': Colors.cyan},
      {'name': 'Hotels', 'icon': Icons.hotel, 'color': Colors.blue},
      {'name': 'Flights', 'icon': Icons.flight, 'color': Colors.lightBlue},
      {
        'name': 'Public Transport',
        'icon': Icons.directions_bus,
        'color': Colors.green
      },
      {
        'name': 'Taxi & Rideshare',
        'icon': Icons.local_taxi,
        'color': Colors.yellow
      },
      {'name': 'Car Maintenance', 'icon': Icons.build, 'color': Colors.grey},

      // Financial & Insurance
      {'name': 'Insurance', 'icon': Icons.security, 'color': Colors.blue},
      {
        'name': 'Banking Fees',
        'icon': Icons.account_balance,
        'color': Colors.red
      },
      {'name': 'Investments', 'icon': Icons.trending_up, 'color': Colors.green},
      {'name': 'Savings', 'icon': Icons.savings, 'color': Colors.teal},
      {
        'name': 'Credit Card',
        'icon': Icons.credit_card,
        'color': Colors.orange
      },

      // Family & Pets
      {'name': 'Child Care', 'icon': Icons.child_care, 'color': Colors.pink},
      {'name': 'Pet Care', 'icon': Icons.pets, 'color': Colors.brown},
      {
        'name': 'Veterinary',
        'icon': Icons.medical_services,
        'color': Colors.green
      },
      {'name': 'Gifts', 'icon': Icons.card_giftcard, 'color': Colors.red},
      {
        'name': 'Family Events',
        'icon': Icons.celebration,
        'color': Colors.purple
      },

      // Work & Business
      {'name': 'Office Supplies', 'icon': Icons.work, 'color': Colors.grey},
      {
        'name': 'Business Meals',
        'icon': Icons.business_center,
        'color': Colors.brown
      },
      {
        'name': 'Professional Services',
        'icon': Icons.business,
        'color': Colors.indigo
      },
      {'name': 'Software & Tools', 'icon': Icons.apps, 'color': Colors.blue},

      // Miscellaneous
      {
        'name': 'Charity',
        'icon': Icons.volunteer_activism,
        'color': Colors.red
      },
      {
        'name': 'Subscriptions',
        'icon': Icons.subscriptions,
        'color': Colors.purple
      },
      {'name': 'Legal Services', 'icon': Icons.gavel, 'color': Colors.brown},
      {'name': 'Taxes', 'icon': Icons.receipt_long, 'color': Colors.red},
      {'name': 'Emergency Fund', 'icon': Icons.warning, 'color': Colors.orange},
    ];

    return suggestions
        .where(
            (s) => !existingNames.contains((s['name'] as String).toLowerCase()))
        .toList();
  }

  void _showAddCategoryDialog() {
    _nameController.clear();
    _selectedIcon = Icons.category;
    _selectedColor = Colors.blue;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add New Category'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name Input
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Category Name',
                    hintText: 'e.g., Groceries, Dining Out',
                  ),
                ),
                const SizedBox(height: 20),

                // Icon Selection
                const Text('Choose Icon:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: _availableIcons.length,
                    itemBuilder: (context, index) {
                      final icon = _availableIcons[index];
                      final isSelected = icon == _selectedIcon;
                      return GestureDetector(
                        onTap: () => setDialogState(() => _selectedIcon = icon),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _selectedColor.withOpacity(0.2)
                                : null,
                            border: Border.all(
                              color: isSelected
                                  ? _selectedColor
                                  : Colors.grey.shade300,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            icon,
                            color: isSelected
                                ? _selectedColor
                                : Colors.grey.shade600,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Color Selection
                const Text('Choose Color:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableColors.map((color) {
                    final isSelected = color == _selectedColor;
                    return GestureDetector(
                      onTap: () => setDialogState(() => _selectedColor = color),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.black, width: 3)
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
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
              onPressed: () => _addCategory(),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _addCategory() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a category name')),
      );
      return;
    }

    final newCategory = Category(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      iconCode: _selectedIcon.codePoint,
      colorValue: _selectedColor.value,
    );

    ref.read(appProvider.notifier).addCategory(newCategory);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Category "${newCategory.name}" added successfully!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _addSuggestedCategory(Map<String, dynamic> suggestion) {
    final newCategory = Category(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: suggestion['name'],
      iconCode: suggestion['icon'].codePoint,
      colorValue: suggestion['color'].value,
    );

    ref.read(appProvider.notifier).addCategory(newCategory);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Category "${newCategory.name}" added!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _handleCategoryAction(String action, Category category) {
    switch (action) {
      case 'edit':
        _editCategory(category);
        break;
      case 'duplicate':
        _duplicateCategory(category);
        break;
      case 'delete':
        _deleteCategory(category);
        break;
    }
  }

  void _editCategory(Category category) {
    _nameController.text = category.name;
    _selectedIcon = category.icon;
    _selectedColor = Color(category.colorValue);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Category'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Category Name'),
                ),
                const SizedBox(height: 20),
                // Similar icon and color selection as in add dialog
                // ... (same UI code as _showAddCategoryDialog)
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
                final updatedCategory = Category(
                  id: category.id,
                  name: _nameController.text.trim(),
                  iconCode: _selectedIcon.codePoint,
                  colorValue: _selectedColor.value,
                );
                ref.read(appProvider.notifier).updateCategory(updatedCategory);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Category updated!')),
                );
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _duplicateCategory(Category category) {
    final duplicatedCategory = Category(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '${category.name} Copy',
      iconCode: category.iconCode,
      colorValue: category.colorValue,
    );

    ref.read(appProvider.notifier).addCategory(duplicatedCategory);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Category duplicated!')),
    );
  }

  void _deleteCategory(Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
            'Are you sure you want to delete "${category.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(appProvider.notifier).deleteCategory(category.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Category "${category.name}" deleted'),
                  backgroundColor: AppColors.danger,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
