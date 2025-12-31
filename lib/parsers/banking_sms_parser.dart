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
    
    // Extract transaction date from SMS text
    DateTime? transactionDate = _extractTransactionDate(text);
    
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
    
    // Extract merchant/payee name (common patterns)
    final merchantName = _extractMerchantName(text);
    
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
      transactionDate: transactionDate,
      bankName: 'HDFC Bank',
      merchantName: merchantName,
      extractionMethod: 'hdfc_template',
      rawSMS: text,
      sender: sender,
      failureReasons: failureReasons,
      warnings: warnings,
    );
  }
  
  // Helper method to extract transaction date from SMS text
  static DateTime? _extractTransactionDate(String text) {
    try {
      // Pattern 1: "on DD-MMM-YYYY" or "on DD/MM/YYYY"
      final datePattern1 = RegExp(r'on\s+(\d{1,2}[-/]\w+[-/]\d{2,4})', caseSensitive: false);
      final match1 = datePattern1.firstMatch(text);
      if (match1 != null) {
        final dateStr = match1.group(1)!;
        final date = _parseDateString(dateStr);
        if (date != null) return date;
      }
      
      // Pattern 2: "on DD-MM-YYYY" or "on DD/MM/YYYY"
      final datePattern2 = RegExp(r'on\s+(\d{1,2}[-/]\d{1,2}[-/]\d{2,4})', caseSensitive: false);
      final match2 = datePattern2.firstMatch(text);
      if (match2 != null) {
        final dateStr = match2.group(1)!;
        final date = _parseDateString(dateStr);
        if (date != null) return date;
      }
      
      // Pattern 3: "DD-MMM-YYYY" standalone
      final datePattern3 = RegExp(r'(\d{1,2}[-/]\w{3}[-/]\d{2,4})', caseSensitive: false);
      final match3 = datePattern3.firstMatch(text);
      if (match3 != null) {
        final dateStr = match3.group(1)!;
        final date = _parseDateString(dateStr);
        if (date != null) return date;
      }
    } catch (e) {
      // Return null if parsing fails
    }
    return null;
  }
  
  static DateTime? _parseDateString(String dateStr) {
    try {
      // Simple parsing for common Indian date formats
      final parts = dateStr.split(RegExp(r'[-/]'));
      if (parts.length == 3) {
        int? day = int.tryParse(parts[0]);
        int? year = int.tryParse(parts[2]);
        if (day != null && year != null) {
          // Handle month
          int? month;
          if (int.tryParse(parts[1]) != null) {
            month = int.parse(parts[1]);
          } else {
            // Month name
            final monthNames = {
              'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
              'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12
            };
            month = monthNames[parts[1].toLowerCase().substring(0, 3)];
          }
          
          if (month != null) {
            // Handle 2-digit year
            if (year < 100) {
              year = year < 50 ? 2000 + year : 1900 + year;
            }
            
            return DateTime(year, month, day);
          }
        }
      }
    } catch (e) {
      // Return null if parsing fails
    }
    return null;
  }
  
  static String? _extractMerchantName(String text) {
    try {
      // Pattern 1: "to [merchant]" or "from [merchant]"
      final toPattern = RegExp(r'(?:to|from)\s+([A-Z][A-Za-z\s&]+?)(?:\s+on|\s+via|\s+for|\.|$)', caseSensitive: false);
      final toMatch = toPattern.firstMatch(text);
      if (toMatch != null) {
        final merchant = toMatch.group(1)?.trim();
        if (merchant != null && merchant.length > 2 && merchant.length < 50) {
          return merchant;
        }
      }
      
      // Pattern 2: UPI merchant (UPI/[merchant])
      final upiPattern = RegExp(r'UPI[/-]([A-Za-z0-9]+)', caseSensitive: false);
      final upiMatch = upiPattern.firstMatch(text);
      if (upiMatch != null) {
        return upiMatch.group(1);
      }
      
      // Pattern 3: Merchant name in quotes or brackets
      final quotedPattern = RegExp(r'''["']([^"']+)["']''', caseSensitive: false);
      final quotedMatch = quotedPattern.firstMatch(text);
      if (quotedMatch != null) {
        return quotedMatch.group(1)?.trim();
      }
    } catch (e) {
      // Return null if extraction fails
    }
    return null;
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
    
    // Extract transaction date from SMS text
    final transactionDate = _extractTransactionDate(text);
    
    // Generic account extraction
    final accountRegex = RegExp(r'(?:A/c|Account).*?[xX*]{2,}(\d{4})', caseSensitive: false);
    final accountMatch = accountRegex.firstMatch(text);
    final accountLast4 = accountMatch?.group(1);
    
    // Extract transaction mode
    final modes = ['NEFT', 'IMPS', 'UPI', 'RTGS', 'ATM', 'POS', 'DEBIT CARD', 'CREDIT CARD'];
    final transactionMode = modes.firstWhere(
      (mode) => textLower.contains(mode.toLowerCase()),
      orElse: () => '',
    );
    
    // Extract available balance
    final balanceRegex = RegExp(r'(?:Avl Bal|Available Balance|Balance|Bal)[\s:]*?(?:Rs\.?\s*|₹\s*|INR\s*)([\d,]+(?:\.\d{2})?)', caseSensitive: false);
    final balanceMatch = balanceRegex.firstMatch(text);
    double? availableBalance;
    if (balanceMatch != null) {
      final balanceStr = balanceMatch.group(1)!.replaceAll(',', '');
      availableBalance = double.tryParse(balanceStr);
    }
    
    // Extract merchant/payee name
    final merchantName = _extractMerchantName(text);
    
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
      transactionMode: transactionMode.isEmpty ? null : transactionMode,
      availableBalance: availableBalance,
      transactionDate: transactionDate,
      bankName: bankName,
      merchantName: merchantName,
      extractionMethod: method,
      rawSMS: text,
      sender: sender,
    );
  }
}