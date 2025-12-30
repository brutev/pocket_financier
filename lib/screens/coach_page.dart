import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/stats_service.dart';
// import '../services/gemma_service.dart';

class CoachPage extends StatefulWidget {
  final List<TransactionModel> transactions;
  
  const CoachPage({super.key, required this.transactions});

  @override
  State<CoachPage> createState() => _CoachPageState();
}

class _CoachPageState extends State<CoachPage> {
  final ValueNotifier<String> _adviceNotifier = ValueNotifier<String>('');
  final ValueNotifier<bool> _loadingNotifier = ValueNotifier<bool>(false);
  
  // Configurable values - can be made editable later
  final double _approxIncome = 45000;
  final double _approxEmi = 10000;

  @override
  void dispose() {
    _adviceNotifier.dispose();
    _loadingNotifier.dispose();
    super.dispose();
  }

  String _generatePlaceholderAdvice(MonthlySnapshot snapshot, Flags flags) {
    final buffer = StringBuffer();
    buffer.writeln('Financial Analysis for ${snapshot.monthId}:\n');
    buffer.writeln('Total Income: ₹${snapshot.income.toStringAsFixed(2)}');
    buffer.writeln('Total Expenses: ₹${snapshot.expense.toStringAsFixed(2)}');
    buffer.writeln('Net Savings: ₹${snapshot.savings.toStringAsFixed(2)}');
    buffer.writeln('Savings Rate: ${(snapshot.savingsRate * 100).toStringAsFixed(1)}%\n');
    buffer.writeln('Financial Health Flags:');
    buffer.writeln('• Savings: ${flags.savingsFlag.toUpperCase()}');
    buffer.writeln('• Lifestyle: ${flags.lifestyleFlag.toUpperCase()}');
    buffer.writeln('• Debt: ${flags.debtFlag.toUpperCase()}\n');
    buffer.writeln('Note: AI-powered advice will be available once GemmaService is implemented.');
    return buffer.toString();
  }

  Future<void> _askCoach() async {
    if (widget.transactions.isEmpty) {
      _adviceNotifier.value = 'No data yet. Import SMS first.';
      return;
    }

    _loadingNotifier.value = true;
    _adviceNotifier.value = '';

    try {
      final grouped = StatsService.groupByMonth(widget.transactions);
      final sortedMonths = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
      
      if (sortedMonths.isEmpty) {
        _adviceNotifier.value = 'No monthly data available.';
        return;
      }

      final latestMonth = sortedMonths.first;
      final latestSnapshot = StatsService.buildSnapshotForMonth(latestMonth, grouped[latestMonth]!);
      
      final flags = StatsService.computeFlags(latestSnapshot, _approxEmi, _approxIncome);
      
      // TODO: Implement GemmaService when available
      // final history = sortedMonths.take(3).map((monthId) => 
      //   StatsService.buildSnapshotForMonth(monthId, grouped[monthId]!)
      // ).toList();
      // final advice = await GemmaService.getAdvice(
      //   snapshot: latestSnapshot,
      //   flags: flags,
      //   history: history,
      // );
      
      // Placeholder advice based on flags
      final advice = _generatePlaceholderAdvice(latestSnapshot, flags);
      _adviceNotifier.value = advice;
    } catch (e) {
      _adviceNotifier.value = 'Error getting advice: $e';
    } finally {
      _loadingNotifier.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: _loadingNotifier,
            builder: (context, loading, _) {
              return ElevatedButton(
                onPressed: loading ? null : _askCoach,
                child: loading
                    ? const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Getting Advice...'),
                        ],
                      )
                    : const Text('Ask Coach for This Month'),
              );
            },
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder<String>(
            valueListenable: _adviceNotifier,
            builder: (context, advice, _) {
              if (advice.isEmpty) {
                return const SizedBox.shrink();
              }
              return Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Text(
                        advice,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                'Disclaimer: This is not professional financial advice, just a budgeting helper.',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}