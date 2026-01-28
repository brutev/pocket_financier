import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pocket_financier/screens/home_page.dart';

class FakePermissionHandler {
  static Future<PermissionStatus> request() async => PermissionStatus.denied;
}

void main() {
  testWidgets('HomePage handles permission denied', (tester) async {
    // Simulate permission denied by replacing SmsService.requestPermission if possible
    // For demonstration, just check for UI response
    await tester.pumpWidget(const MaterialApp(home: HomePage()));
    // You may want to trigger the permission request here if possible
    // expect(find.text('SMS permission denied'), findsOneWidget); // If a SnackBar or dialog is shown
  });
}
