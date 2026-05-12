import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/ui/navigation/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppNavigationBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const AppNavigationBar({
    super.key,
    required this.navigationShell,
    required this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 600) {
          return _WideScreenLayout(
            navigationShell: navigationShell,
            scaffoldKey: scaffoldKey,
          );
        } else {
          return _NarrowScreenLayout(
            navigationShell: navigationShell,
            scaffoldKey: scaffoldKey,
          );
        }
      },
    );
  }
}

class _WideScreenLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const _WideScreenLayout({
    required this.navigationShell,
    required this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final labels = [s.home, s.characters, s.races, s.posts];
    final icons = [
      Icons.home_outlined,
      Icons.people_alt_outlined,
      Icons.emoji_people_outlined,
      Icons.note_alt_outlined,
    ];
    final selectedIcons = [
      Icons.home_rounded,
      Icons.people_alt_rounded,
      Icons.emoji_people_rounded,
      Icons.note_alt_rounded,
    ];

    return Scaffold(
      key: scaffoldKey,
      drawer: const AppDrawer(),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) => navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            ),
            labelType: NavigationRailLabelType.all,
            destinations: List.generate(labels.length, (i) {
              return NavigationRailDestination(
                icon: Icon(icons[i]),
                selectedIcon: Icon(selectedIcons[i]),
                label: Text(labels[i]),
              );
            }),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
}

class _NarrowScreenLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const _NarrowScreenLayout({
    required this.navigationShell,
    required this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final labels = [s.home, s.characters, s.races, s.posts];
    final icons = [
      Icons.home_outlined,
      Icons.people_alt_outlined,
      Icons.emoji_people_outlined,
      Icons.note_alt_outlined,
    ];
    final selectedIcons = [
      Icons.home_rounded,
      Icons.people_alt_rounded,
      Icons.emoji_people_rounded,
      Icons.note_alt_rounded,
    ];

    return Scaffold(
      key: scaffoldKey,
      drawer: const AppDrawer(),
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: List.generate(labels.length, (i) {
          return NavigationDestination(
            icon: Icon(icons[i]),
            selectedIcon: Icon(selectedIcons[i]),
            label: labels[i],
          );
        }),
      ),
    );
  }
}
