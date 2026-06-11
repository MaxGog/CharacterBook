import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/data/models/character_model.dart';
import 'package:characterbook/data/models/race_model.dart';
import 'package:characterbook/data/services/character_service.dart';
import 'package:characterbook/data/services/race_service.dart';
import 'package:characterbook/providers/pins_provider.dart';
import 'package:characterbook/ui/screens/home_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MockCharacterService extends ChangeNotifier implements CharacterService {
  @override
  Future<List<Character>> getAllCharacters() async => [];

  @override
  Future<void> saveCharacter(Character character, {int? key}) async {}

  @override
  Future<void> deleteCharacter(Character character) async {}

  @override
  Future<Character> duplicateCharacter(Character character) async => character;

  @override
  Future<void> exportToPdf(BuildContext context, Character character) async {}

  @override
  Future<void> exportToJson(BuildContext context, Character character) async {}

  @override
  Future<void> exportToWord(BuildContext context, Character character) async {}

  @override
  Future<Character?> getCharacterById(String id) async => null;

  @override
  Future<Character?> getCharacterByKey(int key) async => null;

  @override
  Future<List<Character>> getCharactersByRaceId(String raceId) async => [];
}

// Мок для RaceService
class MockRaceService extends ChangeNotifier implements RaceService {
  @override
  Future<List<Race>> getAllRaces() async => [];

  @override
  Future<void> saveRace(Race race, {dynamic key}) async {}

  @override
  Future<void> deleteRace(dynamic key) async {}

  @override
  Future<Race?> getRaceById(String id) async => null;

  @override
  Future<Race?> getRaceByKey(dynamic key) async => null;

  @override
  Future<void> deleteRaceById(String id) async {}

  @override
  Future<List<Race>> getRacesByName(String name) async => [];

  @override
  Future<List<Race>> getRacesByTags(List<String> tags) async => [];

  @override
  Future<List<Race>> getRacesByFolderId(String folderId) async => [];

  @override
  Future<List<Race>> getRacesWithoutFolder() async => [];

  @override
  Future<void> updateRaceLogo(dynamic key, Uint8List? logoBytes) async {}

  @override
  Future<void> updateRaceTags(dynamic key, List<String> tags) async {}

  @override
  Future<void> updateRaceFolder(dynamic key, String? folderId) async {}

  @override
  Future<int> getRacesCount() async => 0;

  @override
  Future<int> getRacesCountInFolder(String folderId) async => 0;

  @override
  Future<List<Race>> searchRaces(String query) async => [];

  @override
  Future<Set<String>> getAllUniqueTags() async => {};

  @override
  Future<Map<String, int>> getPopularTags({int limit = 10}) async => {};

  @override
  Future<Map<String, dynamic>> exportRaceToJson(dynamic key) async => {};

  @override
  Future<int> importRaceFromJson(Map<String, dynamic> json) async => 0;

  @override
  Future<List<int>> importRacesFromJsonList(
          List<Map<String, dynamic>> jsonList) async =>
      [];

  @override
  Future<void> clearAllRaces() async {}

  @override
  Future<List<Race>> getRacesPaginated(
          {int page = 1,
          int pageSize = 20,
          String? folderId,
          List<String>? tags}) async =>
      [];

  @override
  Future<bool> doesRaceExist(String name, {String? excludeId}) async => false;

  @override
  Future<Map<String, dynamic>> getRacesStatistics() async => {};

  @override
  Future<void> exportToPdf(BuildContext context, Race race) async {}

  @override
  Future<void> exportToJson(BuildContext context, Race race) async {}

  @override
  Future<void> exportToWord(BuildContext context, Race race) async {}
}

class MockPinsProvider extends ChangeNotifier implements PinsProvider {
  @override
  Set<String> get pinnedIds => {};

  @override
  Future<void> togglePin(String id) async {}

  @override
  Future<void> setPinned(String id, bool pinned) async {}

  @override
  bool isPinned(String id) => false;
}

Widget createTestableHomeScreen() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<CharacterService>(
          create: (_) => MockCharacterService()),
      ChangeNotifierProvider<RaceService>(create: (_) => MockRaceService()),
      ChangeNotifierProvider<PinsProvider>(create: (_) => MockPinsProvider()),
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
  testWidgets('HomeScreen shows search and menu icons', (tester) async {
    await tester.pumpWidget(createTestableHomeScreen());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byIcon(Icons.account_circle_rounded), findsOneWidget);
  });

  testWidgets('HomeScreen shows SearchBar when search icon is tapped',
      (tester) async {
    await tester.pumpWidget(createTestableHomeScreen());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    expect(find.byType(SearchBar), findsOneWidget);
  });

  testWidgets('HomeScreen shows a FAB (floating button)', (tester) async {
    await tester.pumpWidget(createTestableHomeScreen());
    await tester.pumpAndSettle();

    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
