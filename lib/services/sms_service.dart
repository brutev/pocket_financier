import 'package:flutter/foundation.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/transaction.dart';
import '../data/transaction_db.dart';
import '../parsers/banking_sms_parser.dart';
import '../models/sms_parse_result.dart';
import '../constants/banking_constants.dart';
import '../utils/category_classifier.dart';

class SmsService {
  static final SmsQuery _query = SmsQuery();

  static Future<bool> requestPermission() async {
    final status = await Permission.sms.request();
    return status.isGranted;
  }

  static Future<void> importSms({int daysBack = 90}) async {
    // Check permission first
    final hasPermission = await Permission.sms.isGranted;
    debugPrint('[SmsService] SMS Permission granted: $hasPermission');
    
    if (!hasPermission) {
      debugPrint('[SmsService] Requesting SMS permission...');
      final status = await Permission.sms.request();
      debugPrint('[SmsService] Permission status: $status');
      if (!status.isGranted) {
        debugPrint('[SmsService] SMS permission denied - cannot read SMS');
        return;
      }
    }
    
    try {
      final List<SmsMessage> messages = await _query.querySms(
        kinds: [SmsQueryKind.inbox],
        count: 1000,
      );
      
      // Filter messages from specified days back (default 90 days = 3 months)
      final cutoffDate = DateTime.now().subtract(Duration(days: daysBack));
      final recentMessages = messages.where((msg) => 
        msg.date != null && msg.date!.isAfter(cutoffDate)
      ).toList();
      
      debugPrint('[SmsService] Extracting SMS from last $daysBack days (${recentMessages.length} messages)');

      int total = recentMessages.length;
      int bankSms = 0;
      int processed = 0;
      int inserted = 0;
      
      debugPrint('[SmsService] Found $total recent SMS messages');
      
      if (kDebugMode) {
        // Only log first 10 messages in debug mode
        for (int i = 0; i < recentMessages.length && i < 10; i++) {
          final message = recentMessages[i];
          final sender = message.address ?? 'Unknown';
          final body = message.body ?? 'No body';
          debugPrint('[SmsService] SMS $i: From $sender - ${body.substring(0, body.length > 30 ? 30 : body.length)}...');
        }
      }
      
      for (final message in recentMessages) {
        final sender = message.address ?? '';
        final body = message.body ?? '';
        
        final senderUpper = sender.toUpperCase();
        if (BankingConstants.bankSenders.any((bank) => senderUpper.contains(bank))) {
          bankSms++;
          if (kDebugMode) {
            debugPrint('[SmsService] Bank SMS from $sender: ${body.substring(0, body.length > 50 ? 50 : body.length)}...');
          }
        }
        
        final transaction = _parseTransaction(message);
        if (transaction != null) {
          processed++;
          final result = await TransactionDb.insert(transaction);
          if (result > 0) inserted++;
        }
      }
      
      debugPrint('[SmsService] Import Summary: Total=$total, Bank SMS=$bankSms, Processed=$processed, Inserted=$inserted');
    } catch (e) {
      debugPrint('[SmsService] Error reading SMS: $e');
    }
  }

  static TransactionModel? _parseTransaction(SmsMessage message) {
    final body = message.body ?? '';
    final sender = message.address ?? '';
    
    // Use the new high-accuracy parser
    final result = BankingSmsParser.parse(sender, body);
    
    // Only accept HIGH and MEDIUM confidence results
    if (!result.isValid || result.confidence == ConfidenceLevel.low || result.confidence == ConfidenceLevel.invalid) {
      if (kDebugMode) {
        debugPrint('[SmsService] SMS rejected - Confidence: ${result.confidence}, Reasons: ${result.failureReasons}');
      }
      return null;
    }
    
    if (result.amount == null || result.transactionType == null) {
      return null;
    }
    
    final category = CategoryClassifier.classify(body, result.merchantName);
    final description = body.length > 200 ? '${body.substring(0, 200)}...' : body;
    final date = message.date ?? DateTime.now();
    
    // Extract transaction reference and UPI ID from SMS text
    final refRegex = RegExp(r'(?:Ref|Ref No|Reference|Txn Ref)[\s:]*([A-Z0-9]{8,20})', caseSensitive: false);
    final refMatch = refRegex.firstMatch(body);
    final transactionRef = refMatch?.group(1);
    
    final upiRegex = RegExp(r'UPI[/-]?([A-Z0-9]{12})', caseSensitive: false);
    final upiMatch = upiRegex.firstMatch(body);
    final upiTransactionId = upiMatch?.group(1);

    if (kDebugMode) {
      debugPrint('[SmsService] SMS parsed successfully - Confidence: ${result.confidence}, Method: ${result.extractionMethod}');
    }
    
    return TransactionModel(
      date: date,
      transactionDate: result.transactionDate,
      amount: result.amount!,
      type: result.transactionType!.toLowerCase(),
      description: description,
      category: category,
      accountLast4: result.accountLast4Digits,
      transactionMode: result.transactionMode,
      availableBalance: result.availableBalance,
      bankName: result.bankName,
      transactionRef: transactionRef,
      merchantName: result.merchantName,
      upiTransactionId: upiTransactionId,
    );
  }
}