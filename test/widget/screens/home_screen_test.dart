import 'package:characterbook/data/models/character_model.dart';
import 'package:characterbook/ui/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:characterbook/data/services/character_service.dart';
import 'package:characterbook/data/services/race_service.dart';
import 'package:characterbook/data/services/note_service.dart';
import 'package:characterbook/ui/controllers/home_controller.dart';

class MockCharacterService extends Mock implements CharacterService {}

class MockRaceService extends Mock implements RaceService {}

class MockNoteService extends Mock implements NoteService {}

void main() {
  late MockCharacterService mockCharService;
  late MockRaceService mockRaceService;
  late MockNoteService mockNoteService;
  late HomeController controller;

  setUp(() {
    mockCharService = MockCharacterService();
    mockRaceService = MockRaceService();
    mockNoteService = MockNoteService();

    //when(() => mockCharService.getRecent()).thenReturn([]);
    //when(() => mockRaceService.getRecent()).thenReturn([]);
    //when(() => mockNoteService.getRecent()).thenReturn([]);

    controller = HomeController(
      characterService: mockCharService,
      raceService: mockRaceService
    );
  });

  Widget createTestableWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: controller),
      ],
      child: const MaterialApp(
        home: HomeScreen(),
      ),
    );
  }

  testWidgets('renders AppBar and FAB', (tester) async {
    await tester.pumpWidget(createTestableWidget());
    await tester.pump();

    expect(find.text('Characterbook'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('shows empty state message when no data', (tester) async {
    await tester.pumpWidget(createTestableWidget());
    await tester.pump();

    // Предположим, есть текст "Your characters will appear here"
    expect(find.text('Your characters will appear here'), findsOneWidget);
  });

  testWidgets('displays character keep cards when recent data exists',
      (tester) async {
    final testChar = Character(
      id: '1',
      name: 'Yennefer',
      age: 100,
      gender: 'Female',
      biography: 'Sorceress',
      personality: '',
      appearance: '',
      imageBytes: null,
      referenceImageBytes: null,
      additionalImages: [],
      customFields: [],
      race: null,
      folderId: null,
      tags: [],
    );
    //when(() => mockCharService.).thenReturn([testChar]);

    controller = HomeController(
      characterService: mockCharService,
      raceService: mockRaceService,
    );

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: controller),
      ],
      child: const MaterialApp(home: HomeScreen()),
    ));
    await tester.pump();

    expect(find.text('Yennefer'), findsOneWidget);
  });
}
