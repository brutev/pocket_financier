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
  TransactionData? _result;

  void _extractTransaction() {
    final message = _messageController.text;
    final sender = _senderController.text;
    
    if (message.isEmpty || sender.isEmpty) return;
    
    setState(() {
      _result = SmsExtractorService.extractTransaction(message, sender);
    });
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
            if (_result != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Valid: ${_result!.isValid}', style: TextStyle(
                        color: _result!.isValid ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      )),
                      if (_result!.isValid) ...[
                        Text('Type: ${_result!.transactionType}'),
                        Text('Amount: ₹${_result!.amount}'),
                        if (_result!.accountLast4Digits != null)
                          Text('Account: ****${_result!.accountLast4Digits}'),
                        if (_result!.transactionMode != null)
                          Text('Mode: ${_result!.transactionMode}'),
                        if (_result!.availableBalance != null)
                          Text('Balance: ₹${_result!.availableBalance}'),
                        if (_result!.bankName != null)
                          Text('Bank: ${_result!.bankName}'),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}