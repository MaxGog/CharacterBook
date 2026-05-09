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
import 'package:characterbook/ui/navigation/app_navigation_bar.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppNavigationBar(navigationShell: navigationShell);
      },
      branches: [
        // Ветка: Главная
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
                  builder: (context, state) {
                    final extra = state.extra;
                    if (extra is QuestionnaireTemplate) {
                      return CharacterManagementScreen(template: extra);
                    }
                    return const CharacterManagementScreen();
                  },
                ),
                GoRoute(
                  path: ':characterId/edit',
                  builder: (context, state) {
                    final extra = state.extra;
                    final character = extra is Character ? extra : null;
                    return CharacterManagementScreen(character: character);
                  },
                ),
              ],
            ),
          ],
        ),
        // Ветка: Расы
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/races',
              builder: (context, state) => const RaceListScreen(),
              routes: [
                GoRoute(
                  path: 'create',
                  builder: (context, state) => const RaceManagementScreen(),
                ),
                GoRoute(
                  path: ':raceId/edit',
                  builder: (context, state) {
                    final extra = state.extra;
                    final race = extra is Race ? extra : null;
                    return RaceManagementScreen(race: race);
                  },
                ),
              ],
            ),
          ],
        ),
        // Ветка: Заметки
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/notes',
              builder: (context, state) => const NotesListScreen(),
              routes: [
                GoRoute(
                  path: 'create',
                  builder: (context, state) => const NoteManagementScreen(),
                ),
                GoRoute(
                  path: ':noteId/edit',
                  builder: (context, state) {
                    final extra = state.extra;
                    final note = extra is Note ? extra : null;
                    return NoteManagementScreen(note: note);
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
