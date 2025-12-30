import 'package:flutter/material.dart';
import '../services/sms_extractor_service.dart';
import '../models/transaction_data.dart';

class SmsTestPage extends StatefulWidget {
  const SmsTestPage({super.key});

  @override
  State<SmsTestPage> createState() => _SmsTestPageState();
}

class _SmsTestPageState extends State<SmsTestPage> {
  final _messageController = TextEditingController();
  final _senderController = TextEditingController();
  final ValueNotifier<TransactionData?> _resultNotifier = ValueNotifier<TransactionData?>(null);

  @override
  void dispose() {
    _messageController.dispose();
    _senderController.dispose();
    _resultNotifier.dispose();
    super.dispose();
  }

  void _extractTransaction() {
    final message = _messageController.text;
    final sender = _senderController.text;
    
    if (message.isEmpty || sender.isEmpty) return;
    
    _resultNotifier.value = SmsExtractorService.extractTransaction(message, sender);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SMS Transaction Extractor')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _senderController,
              decoration: const InputDecoration(
                labelText: 'Sender ID',
                hintText: 'e.g., HDFCBK',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _messageController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'SMS Message',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _extractTransaction,
              child: const Text('Extract Transaction'),
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<TransactionData?>(
              valueListenable: _resultNotifier,
              builder: (context, result, _) {
                if (result == null) {
                  return const SizedBox.shrink();
                }
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Valid: ${result.isValid}', style: TextStyle(
                          color: result.isValid ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        )),
                        if (result.isValid) ...[
                          Text('Type: ${result.transactionType}'),
                          Text('Amount: ₹${result.amount}'),
                          if (result.accountLast4Digits != null)
                            Text('Account: ****${result.accountLast4Digits}'),
                          if (result.transactionMode != null)
                            Text('Mode: ${result.transactionMode}'),
                          if (result.availableBalance != null)
                            Text('Balance: ₹${result.availableBalance}'),
                          if (result.bankName != null)
                            Text('Bank: ${result.bankName}'),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}