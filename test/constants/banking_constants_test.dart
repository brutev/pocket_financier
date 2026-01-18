import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_financier/constants/banking_constants.dart';

void main() {
  group('BankingConstants', () {
    test('bankSenders contains expected banks', () {
      expect(BankingConstants.bankSenders.contains('HDFCBK'), true);
      expect(BankingConstants.bankSenders.contains('SBIINB'), true);
      expect(BankingConstants.bankSenders.contains('ICICIB'), true);
      expect(BankingConstants.bankSenders.contains('AXISBK'), true);
      expect(BankingConstants.bankSenders.length, 18);
    });

    test('spamKeywords contains common spam indicators', () {
      expect(BankingConstants.spamKeywords.contains('click here'), true);
      expect(BankingConstants.spamKeywords.contains('prize'), true);
      expect(BankingConstants.spamKeywords.contains('otp'), true);
      expect(BankingConstants.spamKeywords.contains('www.'), true);
    });

    test('spamPatterns contains regex patterns', () {
      expect(BankingConstants.spamPatterns.isNotEmpty, true);
      expect(BankingConstants.spamPatterns.any((p) => p.contains('bonus')), true);
      expect(BankingConstants.spamPatterns.any((p) => p.contains('https?')), true);
    });

    test('creditKeywords contains transaction indicators', () {
      expect(BankingConstants.creditKeywords.contains('credited'), true);
      expect(BankingConstants.creditKeywords.contains('received'), true);
      expect(BankingConstants.creditKeywords.contains('credit'), true);
    });

    test('debitKeywords contains transaction indicators', () {
      expect(BankingConstants.debitKeywords.contains('debited'), true);
      expect(BankingConstants.debitKeywords.contains('paid'), true);
      expect(BankingConstants.debitKeywords.contains('debit'), true);
    });

    test('transactionModes contains payment methods', () {
      expect(BankingConstants.transactionModes.contains('UPI'), true);
      expect(BankingConstants.transactionModes.contains('NEFT'), true);
      expect(BankingConstants.transactionModes.contains('IMPS'), true);
      expect(BankingConstants.transactionModes.contains('ATM'), true);
    });
  });
}
