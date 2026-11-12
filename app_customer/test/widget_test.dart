import 'package:app_customer/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows the sign-in screen after checking the saved session', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const TokoOnlineApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.theme?.useMaterial3, isTrue);
    expect(find.text('Masuk'), findsOneWidget);
  });
}
