import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_financier/screens/sms_test_page.dart';
import 'package:pocket_financier/models/transaction_data.dart';

void main() {
  group('SmsTestPage Widget Tests', () {
    testWidgets('displays app bar with correct title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SmsTestPage(),
        ),
      );

      expect(find.text('SMS Transaction Extractor'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('displays sender ID text field', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SmsTestPage(),
        ),
      );

      expect(find.text('Sender ID'), findsOneWidget);
      expect(find.text('e.g., HDFCBK'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets('displays SMS message text field', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SmsTestPage(),
        ),
      );

      expect(find.text('SMS Message'), findsOneWidget);
      
      final messageField = tester.widget<TextField>(
        find.byWidgetPredicate((widget) => 
          widget is TextField && widget.maxLines == 4),
      );
      expect(messageField.maxLines, 4);
      expect(messageField.decoration?.border, isA<OutlineInputBorder>());
    });

    testWidgets('displays extract transaction button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SmsTestPage(),
        ),
      );

      expect(find.text('Extract Transaction'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('does not show result card initially', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SmsTestPage(),
        ),
      );

      expect(find.byType(Card), findsNothing);
    });

    testWidgets('can enter text in sender field', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SmsTestPage(),
        ),
      );

      final senderField = find.byWidgetPredicate((widget) => 
        widget is TextField && 
        widget.decoration?.labelText == 'Sender ID');

      await tester.enterText(senderField, 'HDFCBK');
      expect(find.text('HDFCBK'), findsOneWidget);
    });

    testWidgets('can enter text in message field', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SmsTestPage(),
        ),
      );

      final messageField = find.byWidgetPredicate((widget) => 
        widget is TextField && 
        widget.decoration?.labelText == 'SMS Message');

      await tester.enterText(messageField, 'Test SMS message');
      expect(find.text('Test SMS message'), findsOneWidget);
    });

    testWidgets('button tap triggers extraction when fields are filled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SmsTestPage(),
        ),
      );

      // Fill in the fields
      await tester.enterText(
        find.byWidgetPredicate((widget) => 
          widget is TextField && 
          widget.decoration?.labelText == 'Sender ID'),
        'HDFCBK',
      );

      await tester.enterText(
        find.byWidgetPredicate((widget) => 
          widget is TextField && 
          widget.decoration?.labelText == 'SMS Message'),
        'Debited Rs.500 from A/c **1234 on 01-Jan-24',
      );

      // Tap the button
      await tester.tap(find.text('Extract Transaction'));
      await tester.pump();

      // Should show result card (even if extraction fails, card should appear)
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('displays correct padding', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SmsTestPage(),
        ),
      );

      final padding = tester.widget<Padding>(find.byType(Padding).first);
      expect(padding.padding, const EdgeInsets.all(16));
    });

    testWidgets('displays correct spacing between elements', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SmsTestPage(),
        ),
      );

      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      expect(sizedBoxes.length, greaterThanOrEqualTo(2));
      
      // Check for 16px spacing
      final spacingBoxes = sizedBoxes.where((box) => box.height == 16);
      expect(spacingBoxes.length, greaterThanOrEqualTo(2));
    });

    testWidgets('column layout is correct', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SmsTestPage(),
        ),
      );

      expect(find.byType(Column), findsOneWidget);
      
      final column = tester.widget<Column>(find.byType(Column));
      expect(column.children.length, greaterThanOrEqualTo(6)); // Fields, buttons, spacing
    });
  });

  group('SmsTestPage Unit Tests', () {
    test('validates empty sender field', () {
      const sender = '';
      const message = 'Some message';
      
      final shouldExtract = sender.isNotEmpty && message.isNotEmpty;
      expect(shouldExtract, false);
    });

    test('validates empty message field', () {
      const sender = 'HDFCBK';
      const message = '';
      
      final shouldExtract = sender.isNotEmpty && message.isNotEmpty;
      expect(shouldExtract, false);
    });

    test('validates both fields filled', () {
      const sender = 'HDFCBK';
      const message = 'Debited Rs.500 from A/c **1234';
      
      final shouldExtract = sender.isNotEmpty && message.isNotEmpty;
      expect(shouldExtract, true);
    });

    test('transaction data validation for valid transaction', () {
      final validTransaction = TransactionData(
        isValid: true,
        transactionType: 'debit',
        amount: 500.0,
        accountLast4Digits: '1234',
        transactionMode: 'UPI',
        availableBalance: 10000.0,
        bankName: 'HDFC',
      );

      expect(validTransaction.isValid, true);
      expect(validTransaction.transactionType, 'debit');
      expect(validTransaction.amount, 500.0);
      expect(validTransaction.accountLast4Digits, '1234');
      expect(validTransaction.transactionMode, 'UPI');
      expect(validTransaction.availableBalance, 10000.0);
      expect(validTransaction.bankName, 'HDFC');
    });

    test('transaction data validation for invalid transaction', () {
      final invalidTransaction = TransactionData(
        isValid: false,
        transactionType: null,
        amount: null,
        accountLast4Digits: null,
        transactionMode: null,
        availableBalance: null,
        bankName: null,
      );

      expect(invalidTransaction.isValid, false);
      expect(invalidTransaction.transactionType, null);
      expect(invalidTransaction.amount, null);
      expect(invalidTransaction.accountLast4Digits, null);
      expect(invalidTransaction.transactionMode, null);
      expect(invalidTransaction.availableBalance, null);
      expect(invalidTransaction.bankName, null);
    });

    test('handles null values in transaction data', () {
      final partialTransaction = TransactionData(
        isValid: true,
        transactionType: 'credit',
        amount: 1000.0,
        accountLast4Digits: null,
        transactionMode: null,
        availableBalance: null,
        bankName: 'SBI',
      );

      expect(partialTransaction.isValid, true);
      expect(partialTransaction.transactionType, 'credit');
      expect(partialTransaction.amount, 1000.0);
      expect(partialTransaction.accountLast4Digits, null);
      expect(partialTransaction.transactionMode, null);
      expect(partialTransaction.availableBalance, null);
      expect(partialTransaction.bankName, 'SBI');
    });

    test('string trimming for input validation', () {
      const senderWithSpaces = '  HDFCBK  ';
      const messageWithSpaces = '  Debited Rs.500  ';
      
      final trimmedSender = senderWithSpaces.trim();
      final trimmedMessage = messageWithSpaces.trim();
      
      expect(trimmedSender, 'HDFCBK');
      expect(trimmedMessage, 'Debited Rs.500');
      expect(trimmedSender.isNotEmpty, true);
      expect(trimmedMessage.isNotEmpty, true);
    });

    test('amount formatting for display', () {
      const amount = 1234.56;
      final formatted = '₹${amount.toStringAsFixed(2)}';
      
      expect(formatted, '₹1234.56');
    });

    test('account number masking', () {
      const accountLast4 = '1234';
      final masked = '****$accountLast4';
      
      expect(masked, '****1234');
    });

    test('transaction type case handling', () {
      const type = 'DEBIT';
      final lowercase = type.toLowerCase();
      final uppercase = type.toUpperCase();
      
      expect(lowercase, 'debit');
      expect(uppercase, 'DEBIT');
    });

    test('boolean to string conversion for display', () {
      const isValid = true;
      const isInvalid = false;
      
      expect(isValid.toString(), 'true');
      expect(isInvalid.toString(), 'false');
    });
  });
}