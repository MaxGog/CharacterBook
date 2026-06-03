import 'package:characterbook/data/models/character_model.dart';
import 'package:characterbook/data/models/note_model.dart';
import 'package:characterbook/data/models/race_model.dart';
import 'package:characterbook/data/models/template_model.dart';
import 'package:characterbook/ui/screens/characters/character_management_screen.dart';
import 'package:characterbook/ui/screens/characters/character_list_screen.dart';
import 'package:characterbook/ui/screens/home_screen.dart';
import 'package:characterbook/ui/screens/notes/note_management_screen.dart';
import 'package:characterbook/ui/screens/notes/note_list_screen.dart';
import 'package:characterbook/ui/screens/races/race_management_screen.dart';
import 'package:characterbook/ui/screens/races/race_list_screen.dart';
import 'package:characterbook/ui/screens/settings/settings_screen.dart';
import 'package:characterbook/ui/screens/settings/swipe_action_settings_screen.dart';
import 'package:characterbook/ui/screens/templates/template_list_screen.dart';
import 'package:characterbook/ui/navigation/app_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final scaffoldKey = GlobalKey<ScaffoldState>();

class SharedAxisPage<T> extends CustomTransitionPage<T> {
  SharedAxisPage({
    required LocalKey key,
    required Widget child,
    bool fullscreenDialog = false,
    Duration duration = const Duration(milliseconds: 300),
  }) : super(
          key: key,
          child: child,
          fullscreenDialog: fullscreenDialog,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _SharedAxisTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              child: child,
            );
          },
        );
}

class _SharedAxisTransition extends StatelessWidget {
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  const _SharedAxisTransition({
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        ));
        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        ));

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
    );
  }
}

class FadeThroughPage<T> extends CustomTransitionPage<T> {
  FadeThroughPage({
    required LocalKey super.key,
    required super.child,
    super.fullscreenDialog,
    super.transitionDuration,
  }) : super(
          reverseTransitionDuration: transitionDuration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );
}

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppNavigationBar(
          navigationShell: navigationShell,
          scaffoldKey: scaffoldKey,
        );
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/characters',
              builder: (context, state) => const CharacterListScreen(),
              routes: [
                GoRoute(
                  path: 'create',
                  parentNavigatorKey: _rootNavigatorKey,
                  pageBuilder: (context, state) {
                    final extra = state.extra;
                    final template =
                        extra is QuestionnaireTemplate ? extra : null;
                    return SharedAxisPage<bool>(
                      key: const ValueKey('character_create'),
                      child: template != null
                          ? CharacterManagementScreen(template: template)
                          : const CharacterManagementScreen(),
                    );
                  },
                ),
                GoRoute(
                  path: ':characterId/edit',
                  parentNavigatorKey: _rootNavigatorKey,
                  pageBuilder: (context, state) {
                    final extra = state.extra;
                    return SharedAxisPage<bool>(
                      key: ValueKey(
                          'character_edit_${state.pathParameters['characterId']}'),
                      child: CharacterManagementScreen(
                        character: extra is Character ? extra : null,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/races',
              builder: (context, state) => const RaceListScreen(),
              routes: [
                GoRoute(
                  path: 'create',
                  parentNavigatorKey: _rootNavigatorKey,
                  pageBuilder: (context, state) => SharedAxisPage<bool>(
                    key: const ValueKey('race_create'),
                    child: const RaceManagementScreen(),
                  ),
                ),
                GoRoute(
                  path: ':raceId/edit',
                  parentNavigatorKey: _rootNavigatorKey,
                  pageBuilder: (context, state) {
                    final extra = state.extra;
                    return SharedAxisPage<bool>(
                      key: ValueKey(
                          'race_edit_${state.pathParameters['raceId']}'),
                      child: RaceManagementScreen(
                          race: extra is Race ? extra : null),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/notes',
              builder: (context, state) => const NotesListScreen(),
              routes: [
                GoRoute(
                  path: 'create',
                  parentNavigatorKey: _rootNavigatorKey,
                  pageBuilder: (context, state) => SharedAxisPage<bool>(
                    key: const ValueKey('note_create'),
                    child: const NoteManagementScreen(),
                  ),
                ),
                GoRoute(
                  path: ':noteId/edit',
                  parentNavigatorKey: _rootNavigatorKey,
                  pageBuilder: (context, state) {
                    final extra = state.extra;
                    return SharedAxisPage<bool>(
                      key: ValueKey(
                          'note_edit_${state.pathParameters['noteId']}'),
                      child: NoteManagementScreen(
                          note: extra is Note ? extra : null),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    // Настройки и шаблоны
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) => SharedAxisPage(
        key: const ValueKey('settings'),
        child: const SettingsScreen(),
      ),
      routes: [
        GoRoute(
          path: 'swipe-actions',
          pageBuilder: (context, state) => SharedAxisPage<bool>(
            key: const ValueKey('swipe_actions'),
            child: const SwipeActionSettingsScreen(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/templates',
      pageBuilder: (context, state) => FadeThroughPage<QuestionnaireTemplate?>(
        key: const ValueKey('templates'),
        child: const TemplatesListScreen(),
      ),
    ),
  ],
);
