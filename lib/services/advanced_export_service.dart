import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:convert';
import '../models/transaction.dart';
import '../models/category.dart';

class AdvancedExportService {
  static const String _appName = 'Budget Tracker';

  // CSV Export Methods
  static Future<String> exportTransactionsToCSV(
    List<Transaction> transactions,
    List<Category> categories, {
    String? customFileName,
  }) async {
    try {
      final headers = [
        'Date',
        'Title',
        'Amount',
        'Type',
        'Category',
        'Description',
        'Created At'
      ];

      final rows = <List<String>>[headers];

      for (final transaction in transactions) {
        final category = categories.firstWhere(
          (c) => c.name == transaction.category,
          orElse: () => Category(
            id: 'unknown',
            name: 'Unknown',
            iconCode: Icons.help.codePoint,
            colorValue: Colors.grey.value,
          ),
        );

        rows.add([
          DateFormat('yyyy-MM-dd').format(transaction.date),
          transaction.title,
          transaction.amount.toStringAsFixed(2),
          transaction.type,
          category.name,
          transaction.note ?? '',
          DateFormat('yyyy-MM-dd HH:mm:ss').format(transaction.date),
        ]);
      }

      final csvData = const ListToCsvConverter().convert(rows);
      final fileName = customFileName ??
          'transactions_${DateFormat('yyyy_MM_dd_HH_mm_ss').format(DateTime.now())}.csv';

      return await _saveFile(csvData, fileName);
    } catch (e) {
      throw Exception('Failed to export CSV: $e');
    }
  }

  static Future<String> exportCategorySummaryToCSV(
    Map<String, double> categoryData,
    String timeframe, {
    String? customFileName,
  }) async {
    try {
      final headers = ['Category', 'Amount', 'Percentage'];
      final rows = <List<String>>[headers];

      final total =
          categoryData.values.fold(0.0, (sum, amount) => sum + amount);

      final sortedCategories = categoryData.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      for (final entry in sortedCategories) {
        final percentage = total > 0 ? (entry.value / total * 100) : 0;
        rows.add([
          entry.key,
          entry.value.toStringAsFixed(2),
          '${percentage.toStringAsFixed(2)}%',
        ]);
      }

      final csvData = const ListToCsvConverter().convert(rows);
      final fileName = customFileName ??
          'category_summary_${timeframe.toLowerCase()}_${DateFormat('yyyy_MM_dd').format(DateTime.now())}.csv';

      return await _saveFile(csvData, fileName);
    } catch (e) {
      throw Exception('Failed to export category summary: $e');
    }
  }

  static Future<String> exportMonthlyTrendsToCSV(
    Map<String, Map<String, double>> monthlyData, {
    String? customFileName,
  }) async {
    try {
      final headers = ['Month', 'Income', 'Expenses', 'Net'];
      final rows = <List<String>>[headers];

      final sortedMonths = monthlyData.keys.toList()..sort();

      for (final month in sortedMonths) {
        final data = monthlyData[month] ?? {};
        final income = data['income'] ?? 0;
        final expenses = data['expenses'] ?? 0;
        final net = income - expenses;

        rows.add([
          month,
          income.toStringAsFixed(2),
          expenses.toStringAsFixed(2),
          net.toStringAsFixed(2),
        ]);
      }

      final csvData = const ListToCsvConverter().convert(rows);
      final fileName = customFileName ??
          'monthly_trends_${DateFormat('yyyy_MM_dd').format(DateTime.now())}.csv';

      return await _saveFile(csvData, fileName);
    } catch (e) {
      throw Exception('Failed to export monthly trends: $e');
    }
  }

  // Backup/Restore Methods
  static Future<String> createFullBackup(
    List<Transaction> transactions,
    List<Category> categories,
    Map<String, dynamic> appSettings, {
    String? customFileName,
  }) async {
    try {
      final backupData = {
        'version': '1.0',
        'exportDate': DateTime.now().toIso8601String(),
        'appName': _appName,
        'transactions': transactions.map((t) => t.toMap()).toList(),
        'categories': categories
            .map((c) => {
                  'id': c.id,
                  'name': c.name,
                  'iconCode': c.iconCode,
                  'colorValue': c.colorValue,
                })
            .toList(),
        'settings': appSettings,
      };

      final jsonString = _formatJson(backupData);
      final fileName = customFileName ??
          'budget_backup_${DateFormat('yyyy_MM_dd_HH_mm_ss').format(DateTime.now())}.json';

      return await _saveFile(jsonString, fileName);
    } catch (e) {
      throw Exception('Failed to create backup: $e');
    }
  }

  static Future<Map<String, dynamic>> importBackup() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result?.files.single.path != null) {
        final file = File(result!.files.single.path!);
        final jsonString = await file.readAsString();
        final backupData = _parseJson(jsonString);

        // Validate backup structure
        if (!_isValidBackup(backupData)) {
          throw Exception('Invalid backup file format');
        }

        return backupData;
      } else {
        throw Exception('No file selected');
      }
    } catch (e) {
      throw Exception('Failed to import backup: $e');
    }
  }

  // Chart Export Methods
  static Future<Uint8List> exportChartAsImage(
    GlobalKey chartKey, {
    double pixelRatio = 2.0,
  }) async {
    try {
      final boundary =
          chartKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Chart widget not found');
      }

      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('Failed to convert chart to image');
      }

      return byteData.buffer.asUint8List();
    } catch (e) {
      throw Exception('Failed to export chart: $e');
    }
  }

  static Future<String> saveChartImage(
    Uint8List imageBytes, {
    String? customFileName,
  }) async {
    try {
      final fileName = customFileName ??
          'chart_${DateFormat('yyyy_MM_dd_HH_mm_ss').format(DateTime.now())}.png';

      return await _saveImageFile(imageBytes, fileName);
    } catch (e) {
      throw Exception('Failed to save chart image: $e');
    }
  }

  // Report Generation Methods
  static Future<String> generateDetailedReport(
    List<Transaction> transactions,
    List<Category> categories,
    String timeframe,
    DateTime selectedDate, {
    String? customFileName,
  }) async {
    try {
      final report = _generateReportContent(
          transactions, categories, timeframe, selectedDate);
      final fileName = customFileName ??
          'detailed_report_${timeframe.toLowerCase()}_${DateFormat('yyyy_MM_dd').format(selectedDate)}.txt';

      return await _saveFile(report, fileName);
    } catch (e) {
      throw Exception('Failed to generate report: $e');
    }
  }

  // Helper Methods
  static Future<String> _saveFile(String content, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(content);
      return file.path;
    } catch (e) {
      // Fallback to downloads directory
      const String downloadsPath = '/storage/emulated/0/Download';
      final file = File('$downloadsPath/$fileName');
      await file.writeAsString(content);
      return file.path;
    }
  }

  static Future<String> _saveImageFile(
      Uint8List imageBytes, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(imageBytes);
      return file.path;
    } catch (e) {
      throw Exception('Failed to save image file: $e');
    }
  }

  static String _formatJson(Map<String, dynamic> data) {
    return jsonEncode(data);
  }

  static Map<String, dynamic> _parseJson(String jsonString) {
    return jsonDecode(jsonString);
  }

  static bool _isValidBackup(Map<String, dynamic> backupData) {
    return backupData.containsKey('version') &&
        backupData.containsKey('transactions') &&
        backupData.containsKey('categories');
  }

  static String _generateReportContent(
    List<Transaction> transactions,
    List<Category> categories,
    String timeframe,
    DateTime selectedDate,
  ) {
    final buffer = StringBuffer();

    buffer.writeln('$_appName - Detailed Financial Report');
    buffer.writeln(
        'Generated: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}');
    buffer.writeln(
        'Report Period: $timeframe (${DateFormat('MMM yyyy').format(selectedDate)})');
    buffer.writeln('${'-' * 50}');
    buffer.writeln();

    // Summary Section
    final income = transactions
        .where((t) => t.type == 'income')
        .fold(0.0, (sum, t) => sum + t.amount);
    final expenses = transactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount);
    final balance = income - expenses;

    buffer.writeln('FINANCIAL SUMMARY');
    buffer.writeln('${'-' * 20}');
    buffer.writeln('Total Income:  \$${income.toStringAsFixed(2)}');
    buffer.writeln('Total Expenses: \$${expenses.toStringAsFixed(2)}');
    buffer.writeln('Net Balance:   \$${balance.toStringAsFixed(2)}');
    buffer.writeln();

    // Category Breakdown
    final categoryTotals = <String, double>{};
    for (final transaction in transactions.where((t) => t.type == 'expense')) {
      categoryTotals[transaction.category] =
          (categoryTotals[transaction.category] ?? 0) + transaction.amount;
    }

    buffer.writeln('EXPENSE BREAKDOWN BY CATEGORY');
    buffer.writeln('${'-' * 35}');
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (final entry in sortedCategories) {
      final percentage = expenses > 0 ? (entry.value / expenses * 100) : 0;
      buffer.writeln(
          '${entry.key.padRight(20)} \$${entry.value.toStringAsFixed(2).padLeft(10)} (${percentage.toStringAsFixed(1)}%)');
    }
    buffer.writeln();

    // Transaction Details
    buffer.writeln('TRANSACTION DETAILS');
    buffer.writeln('${'-' * 25}');

    final sortedTransactions = transactions.toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    for (final transaction in sortedTransactions) {
      final sign = transaction.type == 'income' ? '+' : '-';
      buffer.writeln('${DateFormat('yyyy-MM-dd').format(transaction.date)} | '
          '${transaction.title.padRight(20)} | '
          '$sign\$${transaction.amount.toStringAsFixed(2).padLeft(8)} | '
          '${transaction.category}');
    }

    return buffer.toString();
  }

  // Quick Export Actions
  static Future<void> quickExportTransactions(
    BuildContext context,
    List<Transaction> transactions,
    List<Category> categories,
  ) async {
    try {
      final filePath = await exportTransactionsToCSV(transactions, categories);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                      'Transactions exported successfully!\nSaved to: ${filePath.split('/').last}'),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'VIEW',
              textColor: Colors.white,
              onPressed: () {
                // Open file location or share
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text('Export failed: $e'),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  static Future<void> quickCreateBackup(
    BuildContext context,
    List<Transaction> transactions,
    List<Category> categories,
  ) async {
    try {
      final filePath = await createFullBackup(
        transactions,
        categories,
        {'theme': 'light', 'currency': 'USD'}, // Default settings
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.backup, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                      'Backup created successfully!\nSaved to: ${filePath.split('/').last}'),
                ),
              ],
            ),
            backgroundColor: Colors.blue.shade600,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text('Backup failed: $e'),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
