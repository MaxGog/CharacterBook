import 'package:characterbook/pages/home_page.dart';
import 'package:characterbook/services/google_drive_service.dart';
//import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
//import 'package:googleapis/drive/v2.dart' as drive;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

  /*final googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveFileScope],
    clientId: Platform.isAndroid
        ? '30938139320-eore4ac6681avqqg9skbjqtd18ns14kh.apps.googleusercontent.com'
        : null,
    serverClientId: Platform.isAndroid
        ? '30938139320-jab98e4j0dcgal085475vnum4gitd2dj.apps.googleusercontent.com'
        : null,
  );

  final cloudBackupService = CloudBackupService(googleSignIn);*/

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => LocaleProvider(settingsBox),
        ),
        //Provider<GoogleSignIn>.value(value: googleSignIn),
        //Provider<CloudBackupService>.value(),
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

    //_checkSignIn();
  }

  /*Future<void> _checkSignIn() async {
    try {
      final googleSignIn = context.read<GoogleSignIn>();
      final cloudBackupService = context.read<CloudBackupService>();

      final isSignedIn = await googleSignIn.isSignedIn();
      if (isSignedIn) {
        await cloudBackupService.autoSyncOnLogin(context);
      }
    } catch (e) {
      debugPrint('Ошибка при проверке входа: $e');
    }
  }*/

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      Hive.box<Character>('characters').flush();

      final googleSignIn = context.read<GoogleSignIn>();
      final cloudBackupService = context.read<CloudBackupService>();

      googleSignIn.isSignedIn().then((isSignedIn) {
        if (isSignedIn) {
          cloudBackupService.exportAllToCloud(context);
        }
      });
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
      home: const HomePage(),
    );
  }
}