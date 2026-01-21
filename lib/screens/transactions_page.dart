import 'package:flutter/material.dart';
import '../models/transaction.dart';

class TransactionsPage extends StatelessWidget {
  final List<TransactionModel> transactions;
  
  const TransactionsPage({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {

    if (transactions.isEmpty) {
      return const Center(
        child: Text(
          'No transactions imported yet.\nTap refresh on Home.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    // Log transactions to console
    for (final tx in transactions) {
      // ignore: avoid_print
      print('[TransactionsPage] id: \u001b[32m${tx.id}\u001b[0m, date: ${tx.date}, amount: ${tx.amount}, type: ${tx.type}, category: ${tx.category}, desc: ${tx.description}');
    }

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            title: Text(
              '${tx.type.toUpperCase()} ₹${tx.amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: tx.type == 'credit' ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${tx.date.day}/${tx.date.month}/${tx.date.year} • ${tx.category}'),
                Text(
                  tx.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}