import 'package:flutter/material.dart';
/*import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/connectors/v1.dart';

import '../services/google_drive_service.dart';*/
import 'character_list_page.dart';
import 'note_list_page.dart';
import 'race_list_page.dart';
import 'search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    CharacterListPage(),
    RaceListPage(),
    NotesListPage(),
    SearchPage()
  ];

  @override
  Widget build(BuildContext context) {
    final bool isLargeScreen = MediaQuery.of(context).size.width >= 600;
    //final googleSignIn = context.read<GoogleSignIn>();
    //final cloudBackupService = context.read<CloudBackupService>();

    return Scaffold(
      /*appBar: AppBar(
        title: const Text('CharacterBook'),
        actions: [
          FutureBuilder<bool>(
            future: googleSignIn.isSignedIn(),
            builder: (context, snapshot) {
              final isSignedIn = snapshot.data ?? false;

              return IconButton(
                icon: Icon(isSignedIn ? Icons.cloud_done : Icons.cloud_upload),
                onPressed: () async {
                  if (isSignedIn) {
                    await googleSignIn.signOut();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Вы вышли из аккаунта Google')),
                    );
                  } else {
                    try {
                      await googleSignIn.signIn();
                      await cloudBackupService.autoSyncOnLogin(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Ошибка входа: $e')),
                      );
                    }
                  }
                },
              );
            },
          ),
        ],
      ),*/
      body: Row(
        children: [
          if (isLargeScreen)
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.people_alt_outlined),
                  selectedIcon: Icon(Icons.people_alt),
                  label: Text('Персонажи'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.emoji_people_outlined),
                  selectedIcon: Icon(Icons.emoji_people),
                  label: Text('Расы'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.note_alt_outlined),
                  selectedIcon: Icon(Icons.note_alt),
                  label: Text('Посты'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.search),
                  selectedIcon: Icon(Icons.search_outlined),
                  label: Text('Поиск'),
                ),
              ],
            ),
          Expanded(
            child: _pages[_currentIndex],
          ),
        ],
      ),
      bottomNavigationBar: !isLargeScreen
          ? NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.people_alt_outlined),
            selectedIcon: Icon(Icons.people_alt),
            label: 'Персонажи',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_people_outlined),
            selectedIcon: Icon(Icons.emoji_people),
            label: 'Расы',
          ),
          NavigationDestination(
            icon: Icon(Icons.note_alt_outlined),
            selectedIcon: Icon(Icons.note_alt),
            label: 'Посты',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            selectedIcon: Icon(Icons.search_outlined),
            label: 'Поиск',
          ),
        ],
      )
          : null,
    );
  }
}