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
  testWidgets('HomeScreen отображает поисковую строку и кнопку меню',
      (tester) async {
    await tester.pumpWidget(createTestableHomeScreen());
    await tester.pumpAndSettle();

    expect(find.byType(SearchBar), findsOneWidget);

    expect(find.byIcon(Icons.account_circle_rounded), findsOneWidget);

    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('HomeScreen показывает FAB (плавающую кнопку)', (tester) async {
    await tester.pumpWidget(createTestableHomeScreen());
    await tester.pumpAndSettle();

    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('Пустое состояние отображается при отсутствии данных',
      (tester) async {
    await tester.pumpWidget(createTestableHomeScreen());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);

    expect(find.text('Нет контента'), findsOneWidget);
  });
}
