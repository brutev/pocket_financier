import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../data/transaction_db.dart';

class DebugPage extends StatefulWidget {
  const DebugPage({super.key});

  @override
  State<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  final ValueNotifier<List<TransactionModel>> _transactionsNotifier = ValueNotifier<List<TransactionModel>>([]);
  final ValueNotifier<double> _totalCreditNotifier = ValueNotifier<double>(0);
  final ValueNotifier<double> _totalDebitNotifier = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _transactionsNotifier.dispose();
    _totalCreditNotifier.dispose();
    _totalDebitNotifier.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final transactions = await TransactionDb.getAll();
    final credit = transactions.where((t) => t.type == 'credit').fold(0.0, (sum, t) => sum + t.amount);
    final debit = transactions.where((t) => t.type == 'debit').fold(0.0, (sum, t) => sum + t.amount);
    
    _transactionsNotifier.value = transactions;
    _totalCreditNotifier.value = credit;
    _totalDebitNotifier.value = debit;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Validation')),
      body: ValueListenableBuilder<List<TransactionModel>>(
        valueListenable: _transactionsNotifier,
        builder: (context, transactions, _) {
          return ValueListenableBuilder<double>(
            valueListenable: _totalCreditNotifier,
            builder: (context, totalCredit, _) {
              return ValueListenableBuilder<double>(
                valueListenable: _totalDebitNotifier,
                builder: (context, totalDebit, _) {
                  return Column(
                    children: [
                      Card(
                        margin: const EdgeInsets.all(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text('Total Transactions: ${transactions.length}'),
                              Text('Credit Count: ${transactions.where((t) => t.type == 'credit').length}'),
                              Text('Debit Count: ${transactions.where((t) => t.type == 'debit').length}'),
                              Text('Total Credit: ₹${totalCredit.toStringAsFixed(2)}'),
                              Text('Total Debit: ₹${totalDebit.toStringAsFixed(2)}'),
                              Text('Net: ₹${(totalCredit - totalDebit).toStringAsFixed(2)}'),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: transactions.length,
                          itemBuilder: (context, index) {
                            final tx = transactions[index];
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
                  );
                },
              );
            },
          );
        },
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