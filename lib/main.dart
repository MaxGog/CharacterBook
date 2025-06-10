import 'package:characterbook/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'adapters/custom_field_adapter.dart';
import 'generated/l10n.dart';
import 'models/character_model.dart';
import 'models/note_model.dart';
import 'models/race_model.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(CharacterAdapter());
  Hive.registerAdapter(CustomFieldAdapter());
  Hive.registerAdapter(NoteAdapter());
  Hive.registerAdapter(RaceAdapter());

  await Hive.openBox<Character>('characters');
  await Hive.openBox<Note>('notes');
  await Hive.openBox<Race>('races');

  final settingsBox = await Hive.openBox('settings');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => LocaleProvider(settingsBox),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      Hive.box<Character>('characters').flush();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      locale: localeProvider.locale ?? const Locale('ru'),
      title: 'CharacterBook',
      theme: context.watch<ThemeProvider>().lightTheme,
      darkTheme: context.watch<ThemeProvider>().darkTheme,
      themeMode: context.watch<ThemeProvider>().themeMode,
      home: const HomePage(),
    );
  }
}