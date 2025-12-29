import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/stats_service.dart';
import '../services/gemma_service.dart';

class CoachPage extends StatefulWidget {
  final List<TransactionModel> transactions;
  
  const CoachPage({super.key, required this.transactions});

  @override
  State<CoachPage> createState() => _CoachPageState();
}

class _CoachPageState extends State<CoachPage> {
  String _advice = '';
  bool _loading = false;
  
  // Configurable values - can be made editable later
  final double _approxIncome = 45000;
  final double _approxEmi = 10000;

  Future<void> _askCoach() async {
    if (widget.transactions.isEmpty) {
      setState(() {
        _advice = 'No data yet. Import SMS first.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _advice = '';
    });

    try {
      final grouped = StatsService.groupByMonth(widget.transactions);
      final sortedMonths = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
      
      if (sortedMonths.isEmpty) {
        setState(() {
          _advice = 'No monthly data available.';
        });
        return;
      }

      final latestMonth = sortedMonths.first;
      final latestSnapshot = StatsService.buildSnapshotForMonth(latestMonth, grouped[latestMonth]!);
      
      final history = sortedMonths.take(3).map((monthId) => 
        StatsService.buildSnapshotForMonth(monthId, grouped[monthId]!)
      ).toList();
      
      final flags = StatsService.computeFlags(latestSnapshot, _approxEmi, _approxIncome);
      
      final advice = await GemmaService.getAdvice(
        snapshot: latestSnapshot,
        flags: flags,
        history: history,
      );
      
      setState(() {
        _advice = advice;
      });
    } catch (e) {
      setState(() {
        _advice = 'Error getting advice: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: _loading ? null : _askCoach,
            child: _loading 
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
          ),
          const SizedBox(height: 16),
          if (_advice.isNotEmpty)
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Text(
                      _advice,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ),
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