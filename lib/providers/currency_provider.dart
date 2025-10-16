import 'package:flutter_riverpod/flutter_riverpod.dart';

final currencyProvider =
    StateProvider<String>((ref) => 'PKR'); // Default to Pakistani Rupee
