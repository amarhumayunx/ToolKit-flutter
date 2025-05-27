import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize(BuildContext context) async {
    const AndroidInitializationSettings androidInit =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iOSInit = DarwinInitializationSettings(
      requestAlertPermission: false, // Don't request automatically
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: iOSInit,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        debugPrint('Notification tapped: ${response.payload}');
      },
    );
  }

  static Future<bool> requestPermissions() async {
    bool permissionGranted = false;

    try {
      // Request permissions for Android
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        final androidResult = await androidPlugin.requestNotificationsPermission();
        permissionGranted = androidResult ?? false;
      }

      // Request permissions for iOS
      final iOSPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();

      if (iOSPlugin != null) {
        final iOSResult = await iOSPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        permissionGranted = iOSResult ?? false;
      }

      // Save permission status
      if (permissionGranted) {
        await _saveNotificationPermissionStatus(true);
      }

      return permissionGranted;
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
      return false;
    }
  }

  static Future<bool> areNotificationsEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('notifications_enabled') ?? false;
    } catch (e) {
      debugPrint('Error checking notification status: $e');
      return false;
    }
  }

  static Future<void> _saveNotificationPermissionStatus(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', enabled);
    } catch (e) {
      debugPrint('Error saving notification status: $e');
    }
  }

  static Future<void> setNotificationEnabled(bool enabled) async {
    await _saveNotificationPermissionStatus(enabled);
  }

  static Future<void> showExportNotification() async {
    // Check if notifications are enabled before showing
    if (!await areNotificationsEnabled()) {
      debugPrint('Notifications are disabled, skipping notification');
      return;
    }

    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'export_channel',
      'Export Notifications',
      channelDescription: 'Notifications for export actions',
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(
        'Your CV has been exported as PDF!',
        htmlFormatBigText: false,
        contentTitle: 'Export Complete ✅',
        htmlFormatContentTitle: false,
      ),
      ticker: 'CV Export Complete',
    );

    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      subtitle: 'CV Export Complete',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    try {
      await _notificationsPlugin.show(
        0,
        'Export Complete ✅',
        'Your CV has been exported as PDF!',
        notificationDetails,
        payload: 'export_complete',
      );
    } catch (e) {
      debugPrint('Error showing export notification: $e');
    }
  }

  static Future<void> showExportStartNotification() async {
    // Check if notifications are enabled before showing
    if (!await areNotificationsEnabled()) {
      debugPrint('Notifications are disabled, skipping notification');
      return;
    }

    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'export_channel',
      'Export Notifications',
      channelDescription: 'Notifications for export actions',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      showProgress: true,
      indeterminate: true,
    );

    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      subtitle: 'Exporting CV...',
      presentAlert: false,
      presentBadge: false,
      presentSound: false,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    try {
      await _notificationsPlugin.show(
        1,
        'Exporting CV...',
        'Please wait while we prepare your PDF',
        notificationDetails,
        payload: 'export_started',
      );
    } catch (e) {
      debugPrint('Error showing export start notification: $e');
    }
  }

  static Future<void> cancelExportProgressNotification() async {
    try {
      await _notificationsPlugin.cancel(1);
    } catch (e) {
      debugPrint('Error canceling progress notification: $e');
    }
  }

  static Future<void> showErrorNotification(String error) async {
    // Check if notifications are enabled before showing
    if (!await areNotificationsEnabled()) {
      debugPrint('Notifications are disabled, skipping notification');
      return;
    }

    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'export_channel',
      'Export Notifications',
      channelDescription: 'Notifications for export actions',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(
        'There was an error while exporting your CV. Please try again.',
        htmlFormatBigText: false,
        contentTitle: 'Export Failed ❌',
        htmlFormatContentTitle: false,
      ),
    );

    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      subtitle: 'Export Failed',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    try {
      await _notificationsPlugin.show(
        2,
        'Export Failed ❌',
        'There was an error while exporting your CV',
        notificationDetails,
        payload: 'export_failed',
      );
    } catch (e) {
      debugPrint('Error showing error notification: $e');
    }
  }
}