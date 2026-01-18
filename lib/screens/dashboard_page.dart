import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction.dart';
import '../utils/transaction_utils.dart';

class DashboardPage extends StatelessWidget {
  final List<TransactionModel> transactions;
  
  const DashboardPage({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final debitTransactions = transactions.where((tx) => tx.type == 'debit').toList();
    
    if (debitTransactions.isEmpty) {
      return const Center(
        child: Text(
          'No expense data yet.\nImport SMS to see spending breakdown.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    final categoryTotals = TransactionUtils.calculateCategoryTotals(transactions);

    final colors = [Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple, Colors.teal];
    final sections = categoryTotals.entries.map((entry) {
      final index = categoryTotals.keys.toList().indexOf(entry.key);
      return PieChartSectionData(
        color: colors[index % colors.length],
        value: entry.value,
        title: '₹${entry.value.toStringAsFixed(0)}',
        radius: 60,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'Category-wise Spending',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            flex: 2,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categoryTotals.entries.map((entry) {
                final index = categoryTotals.keys.toList().indexOf(entry.key);
                return Chip(
                  backgroundColor: colors[index % colors.length],
                  label: Text(
                    '${entry.key}: ₹${entry.value.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}