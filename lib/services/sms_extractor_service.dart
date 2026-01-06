import '../models/transaction_data.dart';
import '../constants/banking_constants.dart';

class SmsExtractorService {

  static TransactionData extractTransaction(String message, String sender, [DateTime? timestamp]) {
    final msgLower = message.toLowerCase();
    
    // Step 1: Sender validation
    if (!BankingConstants.bankSenders.contains(sender.toUpperCase())) {
      return TransactionData(isValid: false);
    }

    // Step 2: Spam detection
    if (BankingConstants.spamKeywords.any((keyword) => msgLower.contains(keyword))) {
      return TransactionData(isValid: false);
    }

    // Step 3: Transaction type detection
    String? transactionType;
    if (BankingConstants.creditKeywords.any((keyword) => msgLower.contains(keyword))) {
      transactionType = 'CREDIT';
    } else if (BankingConstants.debitKeywords.any((keyword) => msgLower.contains(keyword))) {
      transactionType = 'DEBIT';
    } else {
      return TransactionData(isValid: false);
    }

    // Step 4: Amount extraction
    final amountRegex = RegExp(r'(?:₹|Rs\.?|INR)\s*([\d,]+(?:\.\d{2})?)', caseSensitive: false);
    final amountMatch = amountRegex.firstMatch(message);
    if (amountMatch == null) return TransactionData(isValid: false);
    
    final amountStr = amountMatch.group(1)!.replaceAll(',', '');
    final amount = double.tryParse(amountStr);
    if (amount == null) return TransactionData(isValid: false);

    // Step 5: Account extraction
    final accountRegex = RegExp(r'(?:A\/c|Account|a\/c|A\/C).*?[xX*]{2,}(\d{4})', caseSensitive: false);
    final accountMatch = accountRegex.firstMatch(message);
    final accountLast4 = accountMatch?.group(1);

    // Step 6: Transaction mode
    final transactionMode = BankingConstants.transactionModes.firstWhere(
      (mode) => msgLower.contains(mode.toLowerCase()),
      orElse: () => '',
    );

    // Step 7: Available balance
    final balanceRegex = RegExp(r'(?:Avl Bal|Available Balance|Balance|Bal).*?(?:₹|Rs\.?|INR)\s*([\d,]+(?:\.\d{2})?)', caseSensitive: false);
    final balanceMatch = balanceRegex.firstMatch(message);
    double? availableBalance;
    if (balanceMatch != null) {
      final balanceStr = balanceMatch.group(1)!.replaceAll(',', '');
      availableBalance = double.tryParse(balanceStr);
    }

    // Extract bank name
    final bankRegex = RegExp(r'-\s*([A-Z][A-Za-z\s]+Bank)', caseSensitive: false);
    final bankMatch = bankRegex.firstMatch(message);
    final bankName = bankMatch?.group(1)?.trim();

    return TransactionData(
      isValid: true,
      transactionType: transactionType,
      amount: amount,
      currency: 'INR',
      accountLast4Digits: accountLast4,
      transactionMode: transactionMode.isEmpty ? null : transactionMode,
      availableBalance: availableBalance,
      transactionDate: timestamp,
      bankName: bankName,
    );
  }
}