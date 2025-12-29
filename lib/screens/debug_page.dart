import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../data/transaction_db.dart';

class DebugPage extends StatefulWidget {
  const DebugPage({super.key});

  @override
  State<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  List<TransactionModel> _transactions = [];
  double _totalCredit = 0;
  double _totalDebit = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final transactions = await TransactionDb.getAll();
    final credit = transactions.where((t) => t.type == 'credit').fold(0.0, (sum, t) => sum + t.amount);
    final debit = transactions.where((t) => t.type == 'debit').fold(0.0, (sum, t) => sum + t.amount);
    
    setState(() {
      _transactions = transactions;
      _totalCredit = credit;
      _totalDebit = debit;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Validation')),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('Total Transactions: ${_transactions.length}'),
                  Text('Credit Count: ${_transactions.where((t) => t.type == 'credit').length}'),
                  Text('Debit Count: ${_transactions.where((t) => t.type == 'debit').length}'),
                  Text('Total Credit: ₹${_totalCredit.toStringAsFixed(2)}'),
                  Text('Total Debit: ₹${_totalDebit.toStringAsFixed(2)}'),
                  Text('Net: ₹${(_totalCredit - _totalDebit).toStringAsFixed(2)}'),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                final tx = _transactions[index];
                return ListTile(
                  title: Text('₹${tx.amount} - ${tx.type.toUpperCase()}'),
                  subtitle: Text('${tx.category} | ${tx.date.toString().split(' ')[0]}'),
                  trailing: Text(tx.description.length > 30 
                    ? tx.description.substring(0, 30) + '...' 
                    : tx.description),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await TransactionDb.clearAll();
          _loadData();
        },
        child: const Icon(Icons.delete),
      ),
    );
  }
}