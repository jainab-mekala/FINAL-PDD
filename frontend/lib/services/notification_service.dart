import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static late FlutterLocalNotificationsPlugin _notifications;

  static Future<void> initialize(FlutterLocalNotificationsPlugin plugin) async {
    _notifications = plugin;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await plugin.initialize(settings: initSettings);

    // Firebase Messaging setup
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      showRiskAlert(
        title: notification.title ?? 'ImplantGuard Alert',
        body: notification.body ?? '',
        payload: message.data.toString(),
      );
    }
  }

  static Future<void> showRiskAlert({
    required String title,
    required String body,
    String? payload,
    bool isCritical = false,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'implantguard_alerts',
      'ImplantGuard Alerts',
      channelDescription: 'Critical implant risk notifications',
      importance: Importance.max,
      priority: Priority.high,
      color: Color(0xFF00F0FF),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }

  static Future<void> scheduleMaintenanceReminder({
    required String patientName,
    required String implantId,
    required DateTime scheduledDate,
  }) async {
    // Schedule notification for maintenance reminder
    await showRiskAlert(
      title: '📅 Maintenance Reminder',
      body: '$patientName — Implant assessment due',
      payload: 'implant:$implantId',
    );
  }
}

