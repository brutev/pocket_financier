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

    // --- Monthly Trends Data ---
    final Map<String, double> monthlyIncome = {};
    final Map<String, double> monthlyExpense = {};
    final Map<String, double> monthlySavings = {};
    for (final tx in transactions) {
      final date = tx.effectiveDate;
      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      if (tx.type == 'credit') {
        monthlyIncome[key] = (monthlyIncome[key] ?? 0) + tx.amount;
      } else if (tx.type == 'debit') {
        monthlyExpense[key] = (monthlyExpense[key] ?? 0) + tx.amount;
      }
    }
    for (final key in {...monthlyIncome.keys, ...monthlyExpense.keys}) {
      monthlySavings[key] = (monthlyIncome[key] ?? 0) - (monthlyExpense[key] ?? 0);
    }
    final sortedMonths = monthlyIncome.keys.toSet().union(monthlyExpense.keys.toSet()).toList()
      ..sort((a, b) => a.compareTo(b));

    List<FlSpot> _spots(Map<String, double> map) {
      return List.generate(sortedMonths.length, (i) {
        final key = sortedMonths[i];
        return FlSpot(i.toDouble(), map[key] ?? 0);
      });
    }

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
          // --- Monthly Trends Chart ---
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Monthly Trends', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Expanded(
                  child: LineChart(
                    LineChartData(
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx < 0 || idx >= sortedMonths.length) return const SizedBox.shrink();
                              final label = sortedMonths[idx].split('-');
                              return Text('${label[1]}/${label[0].substring(2)}', style: const TextStyle(fontSize: 10));
                            },
                            interval: 1,
                          ),
                        ),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      minY: 0,
                      lineBarsData: [
                        LineChartBarData(
                          spots: _spots(monthlyIncome),
                          isCurved: true,
                          color: Colors.green,
                          barWidth: 2,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(show: false),
                          // Income
                        ),
                        LineChartBarData(
                          spots: _spots(monthlyExpense),
                          isCurved: true,
                          color: Colors.red,
                          barWidth: 2,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(show: false),
                          // Expense
                        ),
                        LineChartBarData(
                          spots: _spots(monthlySavings),
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 2,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(show: false),
                          // Savings
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: const [
                    SizedBox(width: 8),
                    Icon(Icons.trending_up, color: Colors.green, size: 14), Text(' Income', style: TextStyle(fontSize: 12)),
                    SizedBox(width: 16),
                    Icon(Icons.trending_down, color: Colors.red, size: 14), Text(' Expense', style: TextStyle(fontSize: 12)),
                    SizedBox(width: 16),
                    Icon(Icons.savings, color: Colors.blue, size: 14), Text(' Savings', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
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