import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_financier/utils/category_classifier.dart';

void main() {
  group('CategoryClassifier', () {
    test('classifies food transactions correctly', () {
      expect(CategoryClassifier.classify('Order from Swiggy', null), 'Food');
      expect(CategoryClassifier.classify('Payment at Zomato', null), 'Food');
      expect(CategoryClassifier.classify('Transaction at restaurant', null), 'Food');
      expect(CategoryClassifier.classify('Paid at Dominos', null), 'Food');
      expect(CategoryClassifier.classify('', 'Zomato'), 'Food');
    });

    test('classifies shopping transactions correctly', () {
      expect(CategoryClassifier.classify('Purchase from Amazon', null), 'Shopping');
      expect(CategoryClassifier.classify('Order at Flipkart', null), 'Shopping');
      expect(CategoryClassifier.classify('Shopping at mall', null), 'Shopping');
      expect(CategoryClassifier.classify('', 'Amazon Pay'), 'Shopping');
    });

    test('classifies fuel transactions correctly', () {
      expect(CategoryClassifier.classify('Fuel at HPCL', null), 'Fuel');
      expect(CategoryClassifier.classify('Petrol purchase', null), 'Fuel');
      expect(CategoryClassifier.classify('Payment at BPCL', null), 'Fuel');
    });

    test('classifies rent transactions correctly', () {
      expect(CategoryClassifier.classify('Monthly rent payment', null), 'Rent');
      expect(CategoryClassifier.classify('Paid rent', null), 'Rent');
      expect(CategoryClassifier.classify('', 'Rent payment'), 'Rent');
    });

    test('classifies bills transactions correctly', () {
      expect(CategoryClassifier.classify('Electricity bill payment', null), 'Bills');
      expect(CategoryClassifier.classify('Mobile recharge', null), 'Bills');
      expect(CategoryClassifier.classify('Prepaid mobile', null), 'Bills');
      expect(CategoryClassifier.classify('DTH recharge', null), 'Bills');
    });

    test('classifies investments transactions correctly', () {
      expect(CategoryClassifier.classify('invested in a mutual fund', null), 'Investments');
      expect(CategoryClassifier.classify('payment for SIP', 'some broker'), 'Investments');
      expect(CategoryClassifier.classify('purchase of STOCKS', null), 'Investments');
      expect(CategoryClassifier.classify('equity payment was successful', null), 'Investments');
    });

    test('classifies unknown transactions as Other', () {
      expect(CategoryClassifier.classify('Random transaction', null), 'Other');
      expect(CategoryClassifier.classify('Payment for service', null), 'Other');
      expect(CategoryClassifier.classify('Transfer to friend', null), 'Other');
    });

    test('handles empty SMS body and merchant name', () {
      expect(CategoryClassifier.classify('', null), 'Other');
      expect(CategoryClassifier.classify('', ''), 'Other');
    });


  });
}
