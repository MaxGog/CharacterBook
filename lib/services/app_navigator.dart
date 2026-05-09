import 'package:characterbook/services/file_picker_service.dart';
import 'package:characterbook/ui/screens/characters/character_management_screen.dart';
import 'package:characterbook/ui/screens/settings/settings_screen.dart';
import 'package:characterbook/ui/widgets/overlay_notification.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class AppNavigator {
  static BuildContext? get context => appNavigatorKey.currentContext;

  static void openSettings() {
    appNavigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  static void openNewCharacter() {
    appNavigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => const CharacterManagementScreen()),
    );
  }

  static void openFilePicker() {
    final ctx = context;
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

  static void showSuccess(String message) {
    showNotification(message, type: OverlayNotificationType.success);
  }

  static void showError(String message) {
    showNotification(message, type: OverlayNotificationType.error);
  }

  static void showInfo(String message) {
    showNotification(message, type: OverlayNotificationType.info);
  }

  static void showSnackBar(String message, {bool isError = false}) {
    final messenger = appNavigatorKey.currentState?.context
        .findRootAncestorStateOfType<ScaffoldMessengerState>();
    if (messenger != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : null,
        ),
      );
    }
  }
}
