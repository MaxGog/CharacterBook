import 'package:characterbook/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final GlobalKey<ScaffoldMessengerState> messengerKey;

  NotificationService(this.messengerKey);

  void showSuccess(String message) {
    messengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void showError(String message) {
    messengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void showBackupSuccess() {
    showSuccess(S.current.local_backup_success);
  }

  void showBackupError(String error) {
    showError('${S.current.local_backup_error}: $error');
  }

  void showRestoreSuccess() {
    showSuccess(S.current.local_restore_success);
  }

  void showRestoreError(String error) {
    showError('${S.current.local_restore_error}: $error');
  }
}

class LocalNotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );
  }

  Future<int?> scheduleNotification({
    required String title,
    required String body,
    required DateTime eventDate,
    required int minutesBefore,
  }) async {
    final scheduledDate = eventDate.subtract(Duration(minutes: minutesBefore));
    if (scheduledDate.isBefore(DateTime.now())) return null;

    const androidDetails = AndroidNotificationDetails(
      'calendar_events',
      'События календаря',
      channelDescription: 'Напоминания о пользовательских событиях',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    final details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    final id = title.hashCode + eventDate.hashCode;
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
    return id;
  }

  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> cancelForEvent(String title, DateTime eventDate) async {
    final id = title.hashCode + eventDate.hashCode;
    await cancelNotification(id);
  }
}
