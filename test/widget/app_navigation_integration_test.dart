import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_financier/screens/home_page.dart';
import 'package:pocket_financier/screens/transactions_page.dart';
import 'package:pocket_financier/screens/dashboard_page.dart';
import 'package:pocket_financier/screens/coach_page.dart';

void main() {
  testWidgets('Navigation between main screens works', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));

    // HomePage should be visible
    expect(find.text('Pocket Financier'), findsOneWidget);

    // Tap Transactions tab by label
    await tester.tap(find.text('Transactions'));
    await tester.pumpAndSettle();
    expect(find.byType(TransactionsPage), findsOneWidget);

    // Tap Dashboard tab by label
    await tester.tap(find.text('Dashboard'));
    await tester.pumpAndSettle();
    expect(find.byType(DashboardPage), findsOneWidget);

    // Tap Coach tab by label
    await tester.tap(find.text('Coach'));
    await tester.pumpAndSettle();
    expect(find.byType(CoachPage), findsOneWidget);

    // Tap Home tab by label
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Pocket Financier'), findsOneWidget);
  });
}
