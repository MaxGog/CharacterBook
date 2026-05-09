import 'package:characterbook/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppNavigationBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const AppNavigationBar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 600) {
          return _WideScreenLayout(navigationShell: navigationShell);
        } else {
          return _NarrowScreenLayout(navigationShell: navigationShell);
        }
      },
    );
  }
}

class _WideScreenLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const _WideScreenLayout({required this.navigationShell});

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
  const _NarrowScreenLayout({required this.navigationShell});

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
