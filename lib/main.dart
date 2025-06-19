import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'package:characterbook/ui/pages/home_page.dart';
import 'package:characterbook/services/file_handler.dart';

import 'adapters/custom_field_adapter.dart';
import 'services/file_handler_wrapper.dart';
import 'generated/l10n.dart';
import 'models/character_model.dart';
import 'models/note_model.dart';
import 'models/race_model.dart';
import 'models/template_model.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(CharacterAdapter());
  Hive.registerAdapter(CustomFieldAdapter());
  Hive.registerAdapter(NoteAdapter());
  Hive.registerAdapter(RaceAdapter());
  Hive.registerAdapter(QuestionnaireTemplateAdapter());

  await Hive.openBox<Character>('characters');
  await Hive.openBox<Note>('notes');
  await Hive.openBox<Race>('races');
  await Hive.openBox<QuestionnaireTemplate>('templates');

  final settingsBox = await Hive.openBox('settings');

  FileHandler.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      Hive.box<Character>('characters').flush();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final themeProvider = context.watch<ThemeProvider>();

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
      theme: themeProvider.lightTheme,
      darkTheme: themeProvider.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const FileHandlerWrapper(child: HomePage()),
    );
  }
}