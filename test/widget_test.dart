// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:prison_management_system/main.dart';
import 'package:prison_management_system/authentication/screens/login_screen.dart';

void main() {
  testWidgets('app builds successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const PrisonApp());

    expect(find.byType(MaterialApp), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
