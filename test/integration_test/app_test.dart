import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:characterbook/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Can navigate to Characters tab', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    final charactersTab = find.byIcon(Icons.people);
    await tester.tap(charactersTab);
    await tester.pumpAndSettle();

    expect(find.text('Characters'), findsOneWidget);
  });
}
