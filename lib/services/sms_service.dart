import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/transaction.dart';
import '../data/transaction_db.dart';
import '../parsers/banking_sms_parser.dart';
import '../models/sms_parse_result.dart';

class SmsService {
  static final SmsQuery _query = SmsQuery();
  static const _bankSenders = {'HDFCBK', 'SBIINB', 'ICICIB', 'AXISBK', 'PNBSMS', 'SCBANK', 'CITIBK', 'KOTAK', 'YESBNK', 'BOIIND', 'INDBNK', 'UNIONB', 'CANBKS', 'MAHABK', 'FEDBK', 'IDBIBK', 'UCOBKS', 'PSBANK'};
  static const _spamKeywords = ['click here', 'claim now', 'verify now', 'update kyc', 'congratulations', 'won', 'prize', 'lottery', 'reward', 'loan approved', 'instant loan', 'pre-approved', 'pre approved', 'limited time', 'expire', 'suspended', 'blocked', 'call immediately', 'urgent action', 'act now', 'www.', 'http://', 'https://', 'bit.ly', 'tinyurl', 'otp'];

  static Future<bool> requestPermission() async {
    final status = await Permission.sms.request();
    return status.isGranted;
  }

  static Future<void> importSms() async {
    // Check permission first
    final hasPermission = await Permission.sms.isGranted;
    print('SMS Permission granted: $hasPermission');
    
    if (!hasPermission) {
      print('Requesting SMS permission...');
      final status = await Permission.sms.request();
      print('Permission status: $status');
      if (!status.isGranted) {
        print('SMS permission denied - cannot read SMS');
        return;
      }
    }
    
    try {
      final List<SmsMessage> messages = await _query.querySms(
        kinds: [SmsQueryKind.inbox],
        count: 1000,
      );
      
      // Filter messages from last 1 month
      final oneMonthAgo = DateTime.now().subtract(const Duration(days: 30));
      final recentMessages = messages.where((msg) => 
        msg.date != null && msg.date!.isAfter(oneMonthAgo)
      ).toList();
      
      print('Extracting SMS from last 1 month (${recentMessages.length} messages)');

      int total = recentMessages.length;
      int bankSms = 0;
      int processed = 0;
      int inserted = 0;
      
      print('Found $total recent SMS messages');
      
      for (int i = 0; i < recentMessages.length && i < 10; i++) {
        final message = recentMessages[i];
        final sender = message.address ?? 'Unknown';
        final body = message.body ?? 'No body';
        print('SMS $i: From $sender - ${body.substring(0, body.length > 30 ? 30 : body.length)}...');
      }
      
      for (final message in recentMessages) {
        final sender = message.address ?? '';
        final body = message.body ?? '';
        
        final senderUpper = sender.toUpperCase();
        if (_bankSenders.any((bank) => senderUpper.contains(bank))) {
          bankSms++;
          print('Bank SMS from $sender: ${body.substring(0, body.length > 50 ? 50 : body.length)}...');
        }
        
        final transaction = _parseTransaction(message);
        if (transaction != null) {
          processed++;
          final result = await TransactionDb.insert(transaction);
          if (result > 0) inserted++;
        }
      }
      
      print('SMS Import: Total $total, Bank SMS $bankSms, Processed $processed, Inserted $inserted');
    } catch (e) {
      print('Error reading SMS: $e');
    }
  }

  static TransactionModel? _parseTransaction(SmsMessage message) {
    final body = message.body ?? '';
    final sender = message.address ?? '';
    
    // Use the new high-accuracy parser
    final result = BankingSmsParser.parse(sender, body);
    
    // Only accept HIGH and MEDIUM confidence results
    if (!result.isValid || result.confidence == ConfidenceLevel.low || result.confidence == ConfidenceLevel.invalid) {
      print('SMS rejected - Confidence: ${result.confidence}, Reasons: ${result.failureReasons}');
      return null;
    }
    
    if (result.amount == null || result.transactionType == null) {
      return null;
    }
    
    final category = _guessCategory(body);
    final description = body.length > 120 ? body.substring(0, 120) + '...' : body;
    final date = message.date ?? DateTime.now();

    print('SMS parsed successfully - Confidence: ${result.confidence}, Method: ${result.extractionMethod}');
    
    return TransactionModel(
      date: date,
      amount: result.amount!,
      type: result.transactionType!.toLowerCase(),
      description: description,
      category: category,
    );
  }

  static String _guessCategory(String body) {
    final bodyLower = body.toLowerCase();
    
    if (bodyLower.contains(RegExp(r'swiggy|zomato|restaurant|food|dominos|kfc|mcdonalds'))) return 'Food';
    if (bodyLower.contains(RegExp(r'amazon|flipkart|myntra|ajio|shopping|mall'))) return 'Shopping';
    if (bodyLower.contains(RegExp(r'fuel|petrol|hpcl|bpcl|iocl|diesel'))) return 'Fuel';
    if (bodyLower.contains('rent')) return 'Rent';
    if (bodyLower.contains(RegExp(r'bill|postpaid|prepaid|electricity|mobile|dth|recharge'))) return 'Bills';
    
    return 'Other';
  }
}