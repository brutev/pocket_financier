import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_financier/screens/home_page.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('HomePage renders and shows title', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));
    expect(find.text('Pocket Financier'), findsOneWidget);
  });
}
