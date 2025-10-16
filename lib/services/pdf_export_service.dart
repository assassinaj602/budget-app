import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';

class PdfExportService {
  /// Export transactions to PDF
  Future<File> exportTransactionsToPdf({
    required List<Transaction> transactions,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final pdf = pw.Document();

    // Calculate statistics
    final income = transactions
        .where((t) => t.type == 'income')
        .fold(0.0, (sum, t) => sum + t.amount);
    final expense = transactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount);
    final balance = income - expense;

    // Group by category
    final Map<String, double> categoryExpenses = {};
    for (final transaction in transactions.where((t) => t.type == 'expense')) {
      categoryExpenses[transaction.category] =
          (categoryExpenses[transaction.category] ?? 0) + transaction.amount;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          _buildHeader(startDate, endDate),
          pw.SizedBox(height: 20),
          _buildSummary(income, expense, balance),
          pw.SizedBox(height: 20),
          _buildCategoryBreakdown(categoryExpenses, expense),
          pw.SizedBox(height: 20),
          _buildTransactionTable(transactions),
          pw.SizedBox(height: 20),
          _buildFooter(),
        ],
      ),
    );

    // Save to file
    final directory = await getApplicationDocumentsDirectory();
    final file = File(
      '${directory.path}/budget_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  pw.Widget _buildHeader(DateTime? startDate, DateTime? endDate) {
    final dateRange = startDate != null && endDate != null
        ? '${DateFormat('MMM d, yyyy').format(startDate)} - ${DateFormat('MMM d, yyyy').format(endDate)}'
        : 'All Time';

    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.indigo,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Budget Report',
            style: pw.TextStyle(
              fontSize: 28,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            dateRange,
            style: const pw.TextStyle(
              fontSize: 14,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Generated: ${DateFormat('MMM d, yyyy HH:mm').format(DateTime.now())}',
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey300,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSummary(double income, double expense, double balance) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('Total Income', '\$${income.toStringAsFixed(2)}',
              PdfColors.green),
          pw.Container(width: 1, height: 60, color: PdfColors.grey300),
          _buildSummaryItem('Total Expense', '\$${expense.toStringAsFixed(2)}',
              PdfColors.red),
          pw.Container(width: 1, height: 60, color: PdfColors.grey300),
          _buildSummaryItem('Balance', '\$${balance.toStringAsFixed(2)}',
              balance >= 0 ? PdfColors.blue : PdfColors.red),
        ],
      ),
    );
  }

  pw.Widget _buildSummaryItem(String label, String value, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 12,
            color: PdfColors.grey600,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildCategoryBreakdown(
      Map<String, double> categoryExpenses, double totalExpense) {
    final sortedCategories = categoryExpenses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Expense by Category',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 12),
        ...sortedCategories.map((entry) {
          final percentage = (entry.value / totalExpense) * 100;
          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Row(
              children: [
                pw.Expanded(
                  flex: 3,
                  child: pw.Text(entry.key),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    '\$${entry.value.toStringAsFixed(2)}',
                    textAlign: pw.TextAlign.right,
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    '${percentage.toStringAsFixed(1)}%',
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(color: PdfColors.grey600),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  pw.Widget _buildTransactionTable(List<Transaction> transactions) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Transaction Details',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 12),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          children: [
            // Header row
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                _buildTableCell('Date', isHeader: true),
                _buildTableCell('Title', isHeader: true),
                _buildTableCell('Category', isHeader: true),
                _buildTableCell('Type', isHeader: true),
                _buildTableCell('Amount', isHeader: true),
              ],
            ),
            // Data rows
            ...transactions.map((transaction) {
              return pw.TableRow(
                children: [
                  _buildTableCell(
                      DateFormat('MMM d, yyyy').format(transaction.date)),
                  _buildTableCell(transaction.title),
                  _buildTableCell(transaction.category),
                  _buildTableCell(
                    transaction.type.toUpperCase(),
                    color: transaction.type == 'income'
                        ? PdfColors.green
                        : PdfColors.red,
                  ),
                  _buildTableCell(
                    '${transaction.type == 'income' ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
                    color: transaction.type == 'income'
                        ? PdfColors.green
                        : PdfColors.red,
                  ),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildTableCell(String text,
      {bool isHeader = false, PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color ?? PdfColors.black,
        ),
      ),
    );
  }

  pw.Widget _buildFooter() {
    return pw.Container(
      alignment: pw.Alignment.center,
      margin: const pw.EdgeInsets.only(top: 20),
      child: pw.Column(
        children: [
          pw.Divider(color: PdfColors.grey400),
          pw.SizedBox(height: 8),
          pw.Text(
            'Budget Tracker App - Your Personal Finance Manager',
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  /// Print PDF
  Future<void> printPdf(File pdfFile) async {
    final bytes = await pdfFile.readAsBytes();
    await Printing.layoutPdf(onLayout: (_) => bytes);
  }

  /// Share PDF
  Future<void> sharePdf(File pdfFile) async {
    await Printing.sharePdf(
      bytes: await pdfFile.readAsBytes(),
      filename: 'budget_report.pdf',
    );
  }
}
