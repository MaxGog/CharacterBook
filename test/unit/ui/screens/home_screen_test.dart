import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/data/services/character_service.dart';
import 'package:characterbook/data/services/race_service.dart';
import 'package:characterbook/ui/screens/home_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class FakeCharacterService extends Fake implements CharacterService {}

class FakeRaceService extends Fake implements RaceService {}

Widget createTestableHomeScreen() {
  return MultiProvider(
    providers: [
      Provider<CharacterService>(create: (_) => FakeCharacterService()),
      Provider<RaceService>(create: (_) => FakeRaceService()),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: const HomeScreen(),
    ),
  );
}

void main() {
  testWidgets('HomeScreen отображает иконки поиска и меню', (tester) async {
    await tester.pumpWidget(createTestableHomeScreen());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.search), findsOneWidget);

    expect(find.byIcon(Icons.account_circle_rounded), findsOneWidget);
  });

  testWidgets('HomeScreen показывает SearchBar при нажатии на поиск',
      (tester) async {
    await tester.pumpWidget(createTestableHomeScreen());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    expect(find.byType(SearchBar), findsOneWidget);
  });

  testWidgets('HomeScreen показывает FAB (плавающую кнопку)', (tester) async {
    await tester.pumpWidget(createTestableHomeScreen());
    await tester.pumpAndSettle();

    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
