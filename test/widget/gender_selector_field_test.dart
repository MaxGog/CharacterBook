import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/ui/widgets/fields/gender_selector_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrapWithMaterialApp({required Widget child}) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: const [
      S.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: S.delegate.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('GenderSelectorField shows selected localized gender',
      (WidgetTester tester) async {
    String? selected;

    await tester.pumpWidget(_wrapWithMaterialApp(
      child: GenderSelectorField(
        initialValue: 'male',
        onChanged: (value) => selected = value,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Male'), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);
  });

  Finder dialogText(String label) {
    return find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byWidgetPredicate(
        (widget) => widget is Text && widget.data == label,
      ),
    );
  }

  testWidgets('GenderSelectorField opens dialog and selects built-in gender',
      (WidgetTester tester) async {
    String? selected;

    await tester.pumpWidget(_wrapWithMaterialApp(
      child: GenderSelectorField(
        initialValue: 'female',
        onChanged: (value) => selected = value,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Female'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_drop_down_rounded));
    await tester.pumpAndSettle();

    final dialog = find.byType(AlertDialog);
    expect(dialog, findsOneWidget);

    expect(find.widgetWithText(ListTile, 'Male'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Female'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Other'), findsOneWidget);

    await tester.tap(find.widgetWithText(ListTile, 'Male'));
    await tester.pumpAndSettle();

    expect(selected, 'male');
    expect(find.byWidgetPredicate(
      (widget) => widget is EditableText && widget.controller.text == 'Male',
    ), findsOneWidget);
  });

  testWidgets('GenderSelectorField allows entering a custom gender',
      (WidgetTester tester) async {
    String? selected;

    await tester.pumpWidget(_wrapWithMaterialApp(
      child: GenderSelectorField(
        initialValue: '',
        onChanged: (value) => selected = value,
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_drop_down_rounded));
    await tester.pumpAndSettle();

    final dialog = find.byType(AlertDialog);
    final customField = find.descendant(of: dialog, matching: find.byType(TextField)).first;
    expect(customField, findsOneWidget);

    await tester.enterText(customField, 'Non-binary');
    await tester.pumpAndSettle();

    await tester.tap(find.descendant(of: dialog, matching: find.widgetWithText(FilledButton, 'Done')));
    await tester.pumpAndSettle();

    expect(selected, 'Non-binary');
    expect(find.byWidgetPredicate(
      (widget) => widget is EditableText && widget.controller.text == 'Non-binary',
    ), findsOneWidget);
  });
}
