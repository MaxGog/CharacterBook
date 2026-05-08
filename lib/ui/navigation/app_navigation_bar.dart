import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/ui/screens/characters/character_list_screen.dart';
import 'package:characterbook/ui/screens/home_screen.dart';
import 'package:characterbook/ui/screens/notes/note_list_screen.dart';
import 'package:characterbook/ui/screens/races/race_list_screen.dart';
import 'package:flutter/material.dart';

class AppNavigationBar extends StatefulWidget {
  const AppNavigationBar({super.key});

  @override
  State<AppNavigationBar> createState() => _AppNavigationBarState();
}

class _AppNavigationBarState extends State<AppNavigationBar>
    with SingleTickerProviderStateMixin {
  static const List<Widget> _pages = <Widget>[
    HomeScreen(),
    CharacterListScreen(),
    RaceListScreen(),
    NotesListScreen(),
  ];

  static const List<IconData> _icons = <IconData>[
    Icons.home_outlined,
    Icons.people_alt_outlined,
    Icons.emoji_people_outlined,
    Icons.note_alt_outlined,
  ];

  static const List<IconData> _selectedIcons = <IconData>[
    Icons.home_rounded,
    Icons.people_alt_rounded,
    Icons.emoji_people_rounded,
    Icons.note_alt_rounded,
  ];

  int _currentIndex = 0;
  late final AnimationController _animationController;
  bool _isRailExtended = false;

  List<String> _getTitles(BuildContext context) => <String>[
        S.of(context).home,
        S.of(context).characters,
        S.of(context).races,
        S.of(context).posts,
      ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleRailExtension() {
    setState(() {
      _isRailExtended = !_isRailExtended;
      if (_isRailExtended) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
    child: LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 600) {
            return _WideScreenLayout(
              currentIndex: _currentIndex,
              pages: _pages,
              titles: _getTitles(context),
              icons: _icons,
              selectedIcons: _selectedIcons,
              onIndexChanged: _updateIndex,
              isRailExtended: _isRailExtended,
              onToggleExtension: _toggleRailExtension,
            );
          }
          return _NarrowScreenLayout(
            currentIndex: _currentIndex,
            pages: _pages,
            titles: _getTitles(context),
            icons: _icons,
            selectedIcons: _selectedIcons,
            onIndexChanged: _updateIndex,
          );
        },
      ),
    );
  }

  void _updateIndex(int index) {
    if (_currentIndex != index) {
      setState(() => _currentIndex = index);
    }
  }
}

/// Адаптация для широких экранов (планшеты, десктоп).
class _WideScreenLayout extends StatelessWidget {
  const _WideScreenLayout({
    required this.currentIndex,
    required this.pages,
    required this.titles,
    required this.icons,
    required this.selectedIcons,
    required this.onIndexChanged,
    required this.isRailExtended,
    required this.onToggleExtension,
  });

  final int currentIndex;
  final List<Widget> pages;
  final List<String> titles;
  final List<IconData> icons;
  final List<IconData> selectedIcons;
  final ValueChanged<int> onIndexChanged;
  final bool isRailExtended;
  final VoidCallback onToggleExtension;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: onIndexChanged,
            extended: isRailExtended,
            leading: IconButton(
              onPressed: onToggleExtension,
              icon: AnimatedRotation(
                turns: isRailExtended ? 0.5 : 0,
                duration: const Duration(milliseconds: 300),
                child: const Icon(Icons.menu),
              ),
            ),
            destinations: List.generate(
              titles.length,
              (index) => NavigationRailDestination(
                icon: Icon(icons[index]),
                selectedIcon: Icon(selectedIcons[index]),
                label: Text(titles[index]),
              ),
            ),
          ),
          Expanded(child: pages[currentIndex]),
        ],
      ),
    );
  }
}

/// Адаптация для узких экранов (телефоны).
class _NarrowScreenLayout extends StatelessWidget {
  const _NarrowScreenLayout({
    required this.currentIndex,
    required this.pages,
    required this.titles,
    required this.icons,
    required this.selectedIcons,
    required this.onIndexChanged,
  });

  final int currentIndex;
  final List<Widget> pages;
  final List<String> titles;
  final List<IconData> icons;
  final List<IconData> selectedIcons;
  final ValueChanged<int> onIndexChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Column(
        children: [
          Expanded(
            child: pages[currentIndex],
          ),
          NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: onIndexChanged,
            destinations: List.generate(
              titles.length,
              (index) => NavigationDestination(
                icon: Icon(icons[index]),
                selectedIcon: Icon(selectedIcons[index]),
                label: titles[index],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
