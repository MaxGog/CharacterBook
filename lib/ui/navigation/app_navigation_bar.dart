import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/ui/screens/characters/character_list_screen.dart';
import 'package:characterbook/ui/screens/home_screen.dart';
import 'package:characterbook/ui/screens/notes/note_list_screen.dart';
import 'package:characterbook/ui/screens/races/race_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  SystemUiOverlayStyle _getSystemOverlayStyle(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
          brightness == Brightness.dark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness:
          brightness == Brightness.dark ? Brightness.light : Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _getSystemOverlayStyle(context),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return constraints.maxWidth >= 600
                ? _WideScreenLayout(
                    currentIndex: _currentIndex,
                    pages: _pages,
                    titles: _getTitles(context),
                    icons: _icons,
                    selectedIcons: _selectedIcons,
                    onIndexChanged: _updateIndex,
                    isRailExtended: _isRailExtended,
                    onToggleExtension: _toggleRailExtension,
                    animationController: _animationController,
                  )
                : _NarrowScreenLayout(
                    currentIndex: _currentIndex,
                    pages: _pages,
                    titles: _getTitles(context),
                    icons: _icons,
                    selectedIcons: _selectedIcons,
                    onIndexChanged: _updateIndex,
                  );
          },
        ),
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
    required this.animationController,
  });

  final int currentIndex;
  final List<Widget> pages;
  final List<String> titles;
  final List<IconData> icons;
  final List<IconData> selectedIcons;
  final ValueChanged<int> onIndexChanged;
  final bool isRailExtended;
  final VoidCallback onToggleExtension;
  final AnimationController animationController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: onIndexChanged,
            extended: isRailExtended,
            leading: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: IconButton(
                onPressed: onToggleExtension,
                icon: const Icon(Icons.menu),
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
          Expanded(
            child: IndexedStack(
              index: currentIndex,
              children: pages,
            ),
          ),
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
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
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
    );
  }
}
