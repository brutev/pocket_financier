import '../models/sms_parse_result.dart';

class BankingSmsParser {
  static const _bankSenders = {
    'HDFCBK', 'SBIINB', 'ICICIB', 'AXISBK', 'PNBSMS', 'SCBANK', 'CITIBK',
    'KOTAK', 'YESBNK', 'BOIIND', 'INDBNK', 'UNIONB', 'CANBKS', 'MAHABK',
    'FEDBK', 'IDBIBK', 'UCOBKS', 'PSBANK'
  };

  static const _spamKeywords = [
    'click here', 'claim now', 'verify now', 'update kyc', 'congratulations',
    'won', 'prize', 'lottery', 'reward', 'loan approved', 'instant loan',
    'pre-approved', 'pre approved', 'limited time', 'expire', 'suspended',
    'blocked', 'call immediately', 'urgent action', 'act now', 'www.',
    'http://', 'https://', 'bit.ly', 'tinyurl', 'otp'
  ];

  static SmsParseResult parse(String sender, String text) {
    try {
      // Layer 1: Sender validation
      final senderUpper = sender.toUpperCase();
      if (!_bankSenders.any((bank) => senderUpper.contains(bank))) {
        return SmsParseResult(
          isValid: false,
          confidence: ConfidenceLevel.invalid,
          extractionMethod: 'sender_validation_failed',
          rawSMS: text,
          sender: sender,
          failureReasons: ['Sender not in whitelist'],
        );
      }

      // Layer 2: Spam detection
      final textLower = text.toLowerCase();
      if (_spamKeywords.any((keyword) => textLower.contains(keyword))) {
        return SmsParseResult(
          isValid: false,
          confidence: ConfidenceLevel.invalid,
          extractionMethod: 'spam_detected',
          rawSMS: text,
          sender: sender,
          failureReasons: ['Spam keywords detected'],
        );
      }

      // Route to bank-specific parser
      if (senderUpper.contains('HDFCBK')) {
        return _parseHdfcSms(sender, text);
      } else if (senderUpper.contains('SBIINB')) {
        return _parseSbiSms(sender, text);
      } else if (senderUpper.contains('ICICIB')) {
        return _parseIciciSms(sender, text);
      } else if (senderUpper.contains('AXISBK')) {
        return _parseAxisSms(sender, text);
      } else {
        return _parseGenericSms(sender, text);
      }
    } catch (e) {
      return SmsParseResult(
        isValid: false,
        confidence: ConfidenceLevel.invalid,
        extractionMethod: 'parsing_error',
        rawSMS: text,
        sender: sender,
        failureReasons: ['Parsing exception: $e'],
      );
    }
  }

  static SmsParseResult _parseHdfcSms(String sender, String text) {
    final textLower = text.toLowerCase();
    
    // HDFC Template: "Your A/c XX[4digits] [credited|debited] with Rs [amount] on [date] via [mode]. Avl Bal: Rs [balance]"
    
    // Extract transaction type
    String? transactionType;
    if (textLower.contains('credited')) {
      transactionType = 'CREDIT';
    } else if (textLower.contains('debited')) {
      transactionType = 'DEBIT';
    }
    
    // Extract amount
    final amountRegex = RegExp(r'(?:Rs\.?\s*|₹\s*)([\d,]+(?:\.\d{2})?)', caseSensitive: false);
    final amountMatch = amountRegex.firstMatch(text);
    double? amount;
    if (amountMatch != null) {
      final amountStr = amountMatch.group(1)!.replaceAll(',', '');
      amount = double.tryParse(amountStr);
    }
    
    // Extract account last 4 digits
    final accountRegex = RegExp(r'A/c\s*XX(\d{4})', caseSensitive: false);
    final accountMatch = accountRegex.firstMatch(text);
    final accountLast4 = accountMatch?.group(1);
    
    // Extract transaction mode
    final modes = ['NEFT', 'IMPS', 'UPI', 'RTGS', 'ATM', 'POS', 'DEBIT CARD', 'CREDIT CARD'];
    final transactionMode = modes.firstWhere(
      (mode) => textLower.contains(mode.toLowerCase()),
      orElse: () => '',
    );
    
    // Extract available balance
    final balanceRegex = RegExp(r'Avl Bal:?\s*(?:Rs\.?\s*|₹\s*)([\d,]+(?:\.\d{2})?)', caseSensitive: false);
    final balanceMatch = balanceRegex.firstMatch(text);
    double? availableBalance;
    if (balanceMatch != null) {
      final balanceStr = balanceMatch.group(1)!.replaceAll(',', '');
      availableBalance = double.tryParse(balanceStr);
    }
    
    // Calculate confidence
    ConfidenceLevel confidence;
    final warnings = <String>[];
    final failureReasons = <String>[];
    
    if (transactionType != null && amount != null && accountLast4 != null && 
        transactionMode.isNotEmpty && availableBalance != null) {
      confidence = ConfidenceLevel.high;
    } else if (transactionType != null && amount != null) {
      confidence = ConfidenceLevel.medium;
      if (accountLast4 == null) warnings.add('Account number not found');
      if (transactionMode.isEmpty) warnings.add('Transaction mode not found');
    } else {
      confidence = ConfidenceLevel.low;
      if (transactionType == null) failureReasons.add('Transaction type not found');
      if (amount == null) failureReasons.add('Amount not found');
    }
    
    // Sanity checks
    if (amount != null && (amount <= 0 || amount > 100000000)) {
      confidence = ConfidenceLevel.low;
      warnings.add('Amount outside reasonable range');
    }
    
    return SmsParseResult(
      isValid: confidence != ConfidenceLevel.invalid,
      confidence: confidence,
      transactionType: transactionType,
      amount: amount,
      accountLast4Digits: accountLast4,
      transactionMode: transactionMode.isEmpty ? null : transactionMode,
      availableBalance: availableBalance,
      bankName: 'HDFC Bank',
      extractionMethod: 'hdfc_template',
      rawSMS: text,
      sender: sender,
      failureReasons: failureReasons,
      warnings: warnings,
    );
  }

  static SmsParseResult _parseSbiSms(String sender, String text) {
    return _parseGenericSms(sender, text, bankName: 'SBI', method: 'sbi_template');
  }

  static SmsParseResult _parseIciciSms(String sender, String text) {
    return _parseGenericSms(sender, text, bankName: 'ICICI Bank', method: 'icici_template');
  }

  static SmsParseResult _parseAxisSms(String sender, String text) {
    return _parseGenericSms(sender, text, bankName: 'Axis Bank', method: 'axis_template');
  }

  static SmsParseResult _parseGenericSms(String sender, String text, {String? bankName, String method = 'generic'}) {
    final textLower = text.toLowerCase();
    
    // Generic transaction type detection
    String? transactionType;
    if (['credited', 'deposited', 'received', 'added', 'cr', 'credit'].any((k) => textLower.contains(k))) {
      transactionType = 'CREDIT';
    } else if (['debited', 'withdrawn', 'paid', 'deducted', 'dr', 'debit', 'spent', 'purchase'].any((k) => textLower.contains(k))) {
      transactionType = 'DEBIT';
    }
    
    // Generic amount extraction
    final amountRegex = RegExp(r'(?:Rs\.?\s*|₹\s*|INR\s*)([\d,]+(?:\.\d{2})?)', caseSensitive: false);
    final amountMatch = amountRegex.firstMatch(text);
    double? amount;
    if (amountMatch != null) {
      final amountStr = amountMatch.group(1)!.replaceAll(',', '');
      amount = double.tryParse(amountStr);
    }
    
    // Generic account extraction
    final accountRegex = RegExp(r'(?:A/c|Account).*?[xX*]{2,}(\d{4})', caseSensitive: false);
    final accountMatch = accountRegex.firstMatch(text);
    final accountLast4 = accountMatch?.group(1);
    
    // Calculate confidence
    ConfidenceLevel confidence;
    if (transactionType != null && amount != null && accountLast4 != null) {
      confidence = ConfidenceLevel.medium;
    } else if (transactionType != null && amount != null) {
      confidence = ConfidenceLevel.low;
    } else {
      confidence = ConfidenceLevel.invalid;
    }
    
    return SmsParseResult(
      isValid: confidence != ConfidenceLevel.invalid,
      confidence: confidence,
      transactionType: transactionType,
      amount: amount,
      accountLast4Digits: accountLast4,
      bankName: bankName,
      extractionMethod: method,
      rawSMS: text,
      sender: sender,
    );
  }
}