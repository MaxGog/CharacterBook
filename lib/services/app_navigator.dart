import 'package:characterbook/config/app_router.dart';
import 'package:characterbook/data/models/character_model.dart';
import 'package:characterbook/data/models/note_model.dart';
import 'package:characterbook/data/models/race_model.dart';
import 'package:characterbook/data/models/template_model.dart';
import 'package:characterbook/services/file_picker_service.dart';
import 'package:characterbook/ui/navigation/menu_content.dart';
import 'package:characterbook/ui/widgets/overlay_notification.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppNavigator {
  static BuildContext? get _context => appRouter.routerDelegate.navigatorKey.currentContext;

  static NavigatorState? get navigator => appRouter.routerDelegate.navigatorKey.currentState;

  static void goToHome() => appRouter.go('/home');
  static void goToCharacters() => appRouter.go('/characters');
  static void goToRaces() => appRouter.go('/races');
  static void goToNotes() => appRouter.go('/notes');

  static Future<bool?> openNewCharacter({QuestionnaireTemplate? template}) {
    return appRouter.push<bool>(
      '/characters/create',
      extra: template,
    );
  }

  static Future<bool?> openNewRace() {
    return appRouter.push<bool>('/races/create');
  }

  static Future<bool?> openNewNote() {
    return appRouter.push<bool>('/notes/create');
  }

  static Future<bool?> editCharacter(Character character) {
    return appRouter.push<bool>(
      '/characters/${character.id}/edit',
      extra: character,
    );
  }

  static Future<bool?> editRace(Race race) {
    return appRouter.push<bool>(
      '/races/${race.id}/edit',
      extra: race,
    );
  }

  static Future<bool?> editNote(Note note) {
    return appRouter.push<bool>(
      '/notes/${note.id}/edit',
      extra: note,
    );
  }

  static void openSettings() {
    appRouter.push('/settings');
  }

  static Future<QuestionnaireTemplate?> openTemplates() {
    return appRouter.push<QuestionnaireTemplate>('/templates');
  }

  static Future<bool?> openSwipeActionSettings() {
    return appRouter.push<bool>('/settings/swipe-actions');
  }

  static void openFilePicker() {
    final ctx = _context;
    if (ctx != null) {
      final filePicker = Provider.of<FilePickerService>(ctx, listen: false);
      filePicker.importCharacter();
    }
  }

  static void showNotification(
    String message, {
    OverlayNotificationType type = OverlayNotificationType.success,
    Duration duration = const Duration(seconds: 2),
  }) {
    OverlayNotification.show(message, type: type, duration: duration);
  }

  static void showSuccess(String message) =>
      showNotification(message, type: OverlayNotificationType.success);
  static void showError(String message) =>
      showNotification(message, type: OverlayNotificationType.error);
  static void showInfo(String message) =>
      showNotification(message, type: OverlayNotificationType.info);

  static void openMenu(BuildContext context) {
    if (MediaQuery.of(context).size.width >= 600) {
      scaffoldKey.currentState?.openDrawer();
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (ctx, scrollController) => Container(
            decoration: BoxDecoration(
              color: Theme.of(ctx).colorScheme.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              children: [
                // drag handle
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 4),
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(ctx)
                        .colorScheme
                        .onSurfaceVariant
                        .withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: MenuContent(scrollController: scrollController),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
