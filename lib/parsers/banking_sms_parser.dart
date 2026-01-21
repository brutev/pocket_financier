import '../models/sms_parse_result.dart';
import '../constants/banking_constants.dart';

class BankingSmsParser {

  static SmsParseResult parse(String sender, String text) {
        // Improved filter: Ignore credit card bill reminders for all banks
        final textLower = text.toLowerCase();
        if (textLower.contains('is due on') && textLower.contains('minimum amount due')) {
          return SmsParseResult(
            isValid: false,
            confidence: ConfidenceLevel.invalid,
            extractionMethod: 'bill_reminder_general',
            rawSMS: text,
            sender: sender,
            failureReasons: ['Credit card bill reminder, not a transaction'],
          );
        }
    try {
      // Layer 1: Sender validation
      final senderUpper = sender.toUpperCase();
      if (!BankingConstants.bankSenders.any((bank) => senderUpper.contains(bank))) {
        return SmsParseResult(
          isValid: false,
          confidence: ConfidenceLevel.invalid,
          extractionMethod: 'sender_validation_failed',
          rawSMS: text,
          sender: sender,
          failureReasons: ['Sender not in whitelist'],
        );
      }

      // Layer 2: Enhanced spam detection
      final textLower = text.toLowerCase();
      
      // Check spam keywords
      if (BankingConstants.spamKeywords.any((keyword) => textLower.contains(keyword))) {
        return SmsParseResult(
          isValid: false,
          confidence: ConfidenceLevel.invalid,
          extractionMethod: 'spam_keyword_detected',
          rawSMS: text,
          sender: sender,
          failureReasons: ['Spam keywords detected'],
        );
      }
      
      // Check spam patterns
      for (final pattern in BankingConstants.spamPatterns) {
        if (RegExp(pattern, caseSensitive: false).hasMatch(text)) {
          return SmsParseResult(
            isValid: false,
            confidence: ConfidenceLevel.invalid,
            extractionMethod: 'spam_pattern_detected',
            rawSMS: text,
            sender: sender,
            failureReasons: ['Spam pattern detected'],
          );
        }
      }
      
      // Layer 3: Banking legitimacy check
      if (!_isLegitimateTransaction(text)) {
        return SmsParseResult(
          isValid: false,
          confidence: ConfidenceLevel.invalid,
          extractionMethod: 'non_banking_transaction',
          rawSMS: text,
          sender: sender,
          failureReasons: ['Not a legitimate banking transaction'],
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
    
    // Extract transaction type
    String? transactionType;
    if (textLower.contains('credit alert') || textLower.contains('credited')) {
      transactionType = 'CREDIT';
    } else if (textLower.contains('debit alert') || textLower.contains('debited')) {
      transactionType = 'DEBIT';
    }
    
    // Extract amount
    final amountRegex = RegExp(r'(?:Rs\.?\s*|₹\s*)(\d+(?:,\d{3})*(?:\.\d{2})?)', caseSensitive: false);
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
    
    // Extract transaction date
    DateTime? transactionDate = _extractTransactionDate(text);
    
    // Extract VPA/merchant
    String? merchantName = _extractVpaOrMerchant(text);
    
    // Extract transaction mode
    String? transactionMode = _extractTransactionMode(text);
    
    // Extract available balance
    final balanceRegex = RegExp(r'Avl Bal:?\s*(?:Rs\.?\s*|₹\s*)(\d+(?:,\d{3})*(?:\.\d{2})?)', caseSensitive: false);
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
    
    if (transactionType != null && amount != null && accountLast4 != null) {
      confidence = ConfidenceLevel.high;
    } else if (transactionType != null && amount != null) {
      confidence = ConfidenceLevel.medium;
    } else {
      confidence = ConfidenceLevel.low;
      if (transactionType == null) failureReasons.add('Transaction type not found');
      if (amount == null) failureReasons.add('Amount not found');
    }
    
    return SmsParseResult(
      isValid: confidence != ConfidenceLevel.invalid,
      confidence: confidence,
      transactionType: transactionType,
      amount: amount,
      accountLast4Digits: accountLast4,
      transactionMode: transactionMode,
      availableBalance: availableBalance,
      transactionDate: transactionDate,
      bankName: 'HDFC Bank',
      merchantName: merchantName,
      extractionMethod: 'hdfc_enhanced',
      rawSMS: text,
      sender: sender,
      failureReasons: failureReasons,
      warnings: warnings,
    );
  }

  static SmsParseResult _parseAxisSms(String sender, String text) {
    final textLower = text.toLowerCase();

    // Ignore credit card bill reminders (e.g., 'is due on')
    if (textLower.contains('is due on')) {
      return SmsParseResult(
        isValid: false,
        confidence: ConfidenceLevel.invalid,
        extractionMethod: 'axis_bill_reminder',
        rawSMS: text,
        sender: sender,
        failureReasons: ['Credit card bill reminder, not a transaction'],
      );
    }

    // Detect transaction type and account type
    String? transactionType;
    String? accountType = 'SAVINGS'; // Default

    if (textLower.contains('credited') || textLower.contains('payment of') || textLower.contains('received')) {
      transactionType = 'CREDIT';
    } else if (textLower.contains('debited') || textLower.contains('spent')) {
      transactionType = 'DEBIT';
    }

    // Detect account type
    if (textLower.contains('credit card')) {
      accountType = 'CREDIT_CARD';
    } else if (textLower.contains('card no.')) {
      accountType = 'DEBIT_CARD';
    }
    
    // Extract amount - multiple Axis patterns
    final amountRegex = RegExp(r'(?:Payment of |Spent |INR |Rs\.?|₹)\s*(\d+(?:,\d{3})*(?:\.\d{2})?)', caseSensitive: false);
    final amountMatch = amountRegex.firstMatch(text);
    double? amount;
    if (amountMatch != null) {
      final amountStr = amountMatch.group(1)!.replaceAll(',', '');
      amount = double.tryParse(amountStr);
    }
    
    // Extract account/card number - multiple patterns
    String? accountLast4;
    final accountPatterns = [
      RegExp(r'A/c no\.\s*XX(\d{4})', caseSensitive: false),
      RegExp(r'Credit Card XX(\d{4})', caseSensitive: false),
      RegExp(r'Card no\.\s*XX(\d{4})', caseSensitive: false),
    ];
    
    for (final pattern in accountPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        accountLast4 = match.group(1);
        break;
      }
    }
    
    // Extract date and time - multiple Axis formats
    DateTime? transactionDate = _extractAxisDateTime(text);
    
    // Extract transaction mode and details
    String? transactionMode;
    String? merchantName;
    
    // UPI pattern: UPI/P2M/REF/MERCHANT
    final upiMatch = RegExp(r'UPI/([^/]+)/([^/]+)/(.+?)(?:\n|$)', caseSensitive: false).firstMatch(text);
    if (upiMatch != null) {
      transactionMode = 'UPI';
      merchantName = upiMatch.group(3)?.trim();
    }
    
    // NEFT pattern: NEFT/SBIN525351686217/EMPL
    final neftMatch = RegExp(r'NEFT/([^/]+)/(.+?)(?:\.|\n|$)', caseSensitive: false).firstMatch(text);
    if (neftMatch != null) {
      transactionMode = 'NEFT';
      merchantName = neftMatch.group(2)?.trim();
    }
    
    // Direct merchant (for card transactions)
    if (merchantName == null && accountType == 'DEBIT_CARD') {
      final merchantMatch = RegExp(r'\d{2}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2}\s+IST\s*\n?(.+?)(?:\n|Avl)', caseSensitive: false).firstMatch(text);
      if (merchantMatch != null) {
        merchantName = merchantMatch.group(1)?.trim();
      }
    }
    
    // Extract available balance/limit
    double? availableBalance;
    final balancePatterns = [
      RegExp(r'Avl Limit:\s*INR\s*(\d+(?:,\d{3})*(?:\.\d{2})?)', caseSensitive: false),
      RegExp(r'Avl Bal:?\s*(?:INR|Rs\.?)\s*(\d+(?:,\d{3})*(?:\.\d{2})?)', caseSensitive: false),
    ];
    
    for (final pattern in balancePatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final balanceStr = match.group(1)!.replaceAll(',', '');
        availableBalance = double.tryParse(balanceStr);
        break;
      }
    }
    
    // Calculate confidence
    ConfidenceLevel confidence;
    final warnings = <String>[];
    final failureReasons = <String>[];
    
    if (transactionType != null && amount != null && accountLast4 != null) {
      if (transactionMode != null || merchantName != null) {
        confidence = ConfidenceLevel.high;
      } else {
        confidence = ConfidenceLevel.medium;
        if (transactionMode == null) warnings.add('Transaction mode not found');
      }
    } else {
      confidence = ConfidenceLevel.low;
      if (transactionType == null) failureReasons.add('Transaction type not found');
      if (amount == null) failureReasons.add('Amount not found');
      if (accountLast4 == null) failureReasons.add('Account number not found');
    }
    
    return SmsParseResult(
      isValid: confidence != ConfidenceLevel.invalid,
      confidence: confidence,
      transactionType: transactionType,
      amount: amount,
      accountLast4Digits: accountLast4,
      transactionMode: transactionMode,
      availableBalance: availableBalance,
      transactionDate: transactionDate,
      bankName: 'Axis Bank',
      merchantName: merchantName,
      extractionMethod: 'axis_multi_pattern',
      rawSMS: text,
      sender: sender,
      failureReasons: failureReasons,
      warnings: warnings,
    );
  }

  static SmsParseResult _parseSbiSms(String sender, String text) {
    return _parseGenericSms(sender, text);
  }

  static SmsParseResult _parseIciciSms(String sender, String text) {
    return _parseGenericSms(sender, text);
  }

  static SmsParseResult _parseGenericSms(String sender, String text) {
    final textLower = text.toLowerCase();
    
    // Generic transaction type detection
    String? transactionType;
    if (textLower.contains('credit') || textLower.contains('received')) {
      transactionType = 'CREDIT';
    } else if (textLower.contains('debit') || textLower.contains('paid')) {
      transactionType = 'DEBIT';
    }
    
    // Extract amount
    final amountRegex = RegExp(r'(?:Rs\.?\s*|₹\s*|INR\s*)(\d+(?:,\d{3})*(?:\.\d{2})?)', caseSensitive: false);
    final amountMatch = amountRegex.firstMatch(text);
    double? amount;
    if (amountMatch != null) {
      final amountStr = amountMatch.group(1)!.replaceAll(',', '');
      amount = double.tryParse(amountStr);
    }
    
    // Extract account
    final accountRegex = RegExp(r'(?:A/c|Account)\s*(?:XX|\*\*)(\d{4})', caseSensitive: false);
    final accountMatch = accountRegex.firstMatch(text);
    final accountLast4 = accountMatch?.group(1);
    
    // Extract transaction date
    DateTime? transactionDate = _extractTransactionDate(text);
    
    // Extract transaction mode
    String? transactionMode = _extractTransactionMode(text);
    
    // Extract merchant
    String? merchantName = _extractVpaOrMerchant(text);
    
    // Calculate confidence
    ConfidenceLevel confidence;
    if (transactionType != null && amount != null) {
      confidence = ConfidenceLevel.medium;
    } else {
      confidence = ConfidenceLevel.low;
    }
    
    return SmsParseResult(
      isValid: confidence != ConfidenceLevel.invalid,
      confidence: confidence,
      transactionType: transactionType,
      amount: amount,
      accountLast4Digits: accountLast4,
      transactionMode: transactionMode,
      availableBalance: null,
      transactionDate: transactionDate,
      bankName: 'Unknown Bank',
      merchantName: merchantName,
      extractionMethod: 'generic_parser',
      rawSMS: text,
      sender: sender,
    );
  }

  // Helper methods
  static DateTime? _extractAxisDateTime(String text) {
    try {
      // Pattern 1: "DD-MM-YY, HH:MM:SS" (basic debit)
      final pattern1 = RegExp(r'(\d{2}-\d{2}-\d{2}),\s*(\d{2}:\d{2}:\d{2})', caseSensitive: false);
      final match1 = pattern1.firstMatch(text);
      if (match1 != null) {
        return _parseAxisDateTimeString(match1.group(1)!, match1.group(2)!);
      }
      
      // Pattern 2: "on DD-MM-YY" (credit card payment)
      final pattern2 = RegExp(r'on\s+(\d{2}-\d{2}-\d{2})(?:\s|$)', caseSensitive: false);
      final match2 = pattern2.firstMatch(text);
      if (match2 != null) {
        return _parseAxisDateTimeString(match2.group(1)!, null);
      }
      
      // Pattern 3: "on DD-MM-YY at HH:MM:SS IST" (NEFT credit)
      final pattern3 = RegExp(r'on\s+(\d{2}-\d{2}-\d{2})\s+at\s+(\d{2}:\d{2}:\d{2})\s+IST', caseSensitive: false);
      final match3 = pattern3.firstMatch(text);
      if (match3 != null) {
        return _parseAxisDateTimeString(match3.group(1)!, match3.group(2)!);
      }
      
      // Pattern 4: "DD-MM-YY HH:MM:SS IST" (card spending)
      final pattern4 = RegExp(r'(\d{2}-\d{2}-\d{2})\s+(\d{2}:\d{2}:\d{2})\s+IST', caseSensitive: false);
      final match4 = pattern4.firstMatch(text);
      if (match4 != null) {
        return _parseAxisDateTimeString(match4.group(1)!, match4.group(2)!);
      }
      
      return _extractTransactionDate(text);
    } catch (e) {
      return null;
    }
  }
  
  static DateTime? _parseAxisDateTimeString(String dateStr, String? timeStr) {
    try {
      final dateParts = dateStr.split('-');
      if (dateParts.length == 3) {
        final day = int.tryParse(dateParts[0]);
        final month = int.tryParse(dateParts[1]);
        var year = int.tryParse(dateParts[2]);
        
        if (day != null && month != null && year != null) {
          // Handle 2-digit year
          if (year < 100) {
            year = year < 50 ? 2000 + year : 1900 + year;
          }
          
          if (timeStr != null) {
            final timeParts = timeStr.split(':');
            if (timeParts.length == 3) {
              final hour = int.tryParse(timeParts[0]);
              final minute = int.tryParse(timeParts[1]);
              final second = int.tryParse(timeParts[2]);
              
              if (hour != null && minute != null && second != null) {
                return DateTime(year, month, day, hour, minute, second);
              }
            }
          }
          
          return DateTime(year, month, day);
        }
      }
    } catch (e) {
      // Return null if parsing fails
    }
    return null;
  }

  static DateTime? _extractTransactionDate(String text) {
    try {
      // Pattern 1: "on DD-MM-YY"
      final datePattern1 = RegExp(r'on\s+(\d{1,2}[-/]\d{1,2}[-/]\d{2,4})', caseSensitive: false);
      final match1 = datePattern1.firstMatch(text);
      if (match1 != null) {
        return _parseDateString(match1.group(1)!);
      }
      
      // Pattern 2: "DD-MM-YY" standalone
      final datePattern2 = RegExp(r'(\d{2}-\d{2}-\d{2})(?:,|\s)', caseSensitive: false);
      final match2 = datePattern2.firstMatch(text);
      if (match2 != null) {
        return _parseDateString(match2.group(1)!);
      }
    } catch (e) {
      // Return null if parsing fails
    }
    return null;
  }

  static DateTime? _parseDateString(String dateStr) {
    try {
      final parts = dateStr.split(RegExp(r'[-/]'));
      if (parts.length == 3) {
        final day = int.tryParse(parts[0]);
        final month = int.tryParse(parts[1]);
        var year = int.tryParse(parts[2]);
        
        if (day != null && month != null && year != null) {
          if (year < 100) {
            year = year < 50 ? 2000 + year : 1900 + year;
          }
          return DateTime(year, month, day);
        }
      }
    } catch (e) {
      // Return null if parsing fails
    }
    return null;
  }

  static String? _extractVpaOrMerchant(String text) {
    try {
      // Pattern 1: VPA format
      final vpaPattern = RegExp(r'from VPA\s+([a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+)', caseSensitive: false);
      final vpaMatch = vpaPattern.firstMatch(text);
      if (vpaMatch != null) {
        return vpaMatch.group(1);
      }
      
      // Pattern 2: "to [merchant]" or "from [merchant]"
      final toPattern = RegExp(r'(?:to|from)\s+([A-Z][A-Za-z\s&]+?)(?:\s+on|\s+via|\.|$)', caseSensitive: false);
      final toMatch = toPattern.firstMatch(text);
      if (toMatch != null) {
        final merchant = toMatch.group(1)?.trim();
        if (merchant != null && merchant.length > 2 && merchant.length < 50) {
          return merchant;
        }
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  // Banking legitimacy check
  static bool _isLegitimateTransaction(String text) {
    final textLower = text.toLowerCase();
    
    // Must have account reference for legitimate banking transaction
    final hasAccountRef = RegExp(r'(?:a/c|account|card).*(?:xx|\*\*)\d{4}', caseSensitive: false).hasMatch(text);
    
    // Must have proper transaction indicators
    final hasTransactionIndicator = [
      'debited', 'credited', 'withdrawn', 'deposited', 'paid', 'received'
    ].any((indicator) => textLower.contains(indicator));
    
    // Must NOT be promotional content
    final isPromotional = [
      'welcome', 'bonus', 'free', 'offer', 'join', 'sign up', 'download',
      'install', 'claim', 'win', 'prize', 'reward'
    ].any((promo) => textLower.contains(promo));
    
    // Must have proper amount format (not promotional amounts)
    final hasProperAmount = RegExp(r'(?:rs\.?|inr|₹)\s*\d{3,}', caseSensitive: false).hasMatch(text);
    
    // Legitimate if has account ref, transaction indicator, proper amount, and not promotional
    return hasAccountRef && hasTransactionIndicator && hasProperAmount && !isPromotional;
  }
  static String? _extractTransactionMode(String text) {
    final textLower = text.toLowerCase();
    
    if (textLower.contains('upi') || textLower.contains('vpa')) {
      return 'UPI';
    }
    
    final modes = ['NEFT', 'IMPS', 'RTGS', 'ATM', 'POS', 'DEBIT CARD', 'CREDIT CARD'];
    for (final mode in modes) {
      if (textLower.contains(mode.toLowerCase())) {
        return mode;
      }
    }
    
    return null;
  }
}