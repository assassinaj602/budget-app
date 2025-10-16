import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/currency_provider.dart';
import '../utils/currencies.dart';

class CurrencySelectorScreen extends ConsumerStatefulWidget {
  const CurrencySelectorScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CurrencySelectorScreen> createState() =>
      _CurrencySelectorScreenState();
}

class _CurrencySelectorScreenState
    extends ConsumerState<CurrencySelectorScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CurrencyData> get _filteredCurrencies {
    if (_searchQuery.isEmpty) {
      return worldCurrencies;
    }

    final query = _searchQuery.toLowerCase();
    return worldCurrencies.where((currency) {
      return currency.code.toLowerCase().contains(query) ||
          currency.name.toLowerCase().contains(query) ||
          currency.country.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final currentCurrency = ref.watch(currencyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Currency'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search currency, country, or code...',
                hintStyle: TextStyle(color: Colors.grey.shade600),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade700),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey.shade700),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // Results count
          if (_searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '${_filteredCurrencies.length} currencies found',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ),

          // Currency list
          Expanded(
            child: _filteredCurrencies.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No currencies found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try a different search term',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredCurrencies.length,
                    itemBuilder: (context, index) {
                      final currency = _filteredCurrencies[index];
                      final isSelected = currency.code == currentCurrency;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.grey.shade300,
                          child: Text(
                            currency.symbol,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          '${currency.code} - ${currency.name}',
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : null,
                          ),
                        ),
                        subtitle: Text(currency.country),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle,
                                color: Theme.of(context).primaryColor,
                              )
                            : null,
                        onTap: () {
                          ref.read(currencyProvider.notifier).state =
                              currency.code;
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Currency changed to ${currency.code} (${currency.symbol})',
                              ),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
