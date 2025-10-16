import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    print('Notification tapped: ${response.payload}');
  }

  /// Show immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'budget_app_channel',
      'Budget Notifications',
      channelDescription: 'Notifications for budget tracking',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  /// Schedule a notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'budget_app_channel',
      'Budget Notifications',
      channelDescription: 'Notifications for budget tracking',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  /// Schedule recurring notification
  Future<void> scheduleRecurringNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'budget_app_channel',
      'Budget Notifications',
      channelDescription: 'Notifications for budget tracking',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
      0,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// Budget limit notification
  Future<void> showBudgetLimitNotification({
    required String budgetName,
    required double percentage,
  }) async {
    await showNotification(
      id: budgetName.hashCode,
      title: '⚠️ Budget Alert',
      body:
          'You\'ve used ${percentage.toStringAsFixed(0)}% of your $budgetName budget!',
    );
  }

  /// Budget exceeded notification
  Future<void> showBudgetExceededNotification({
    required String budgetName,
  }) async {
    await showNotification(
      id: budgetName.hashCode + 1,
      title: '🚨 Budget Exceeded',
      body: 'You\'ve exceeded your $budgetName budget!',
    );
  }

  /// Bill reminder notification
  Future<void> scheduleBillReminder({
    required String billName,
    required DateTime dueDate,
    required double amount,
  }) async {
    // Notify 3 days before
    final notificationDate = dueDate.subtract(const Duration(days: 3));

    await scheduleNotification(
      id: billName.hashCode,
      title: '💳 Bill Reminder',
      body:
          '$billName payment of \$${amount.toStringAsFixed(2)} is due on ${dueDate.day}/${dueDate.month}',
      scheduledDate: notificationDate,
    );
  }

  /// Recurring transaction reminder
  Future<void> scheduleRecurringTransactionReminder({
    required String transactionName,
    required int hour,
    required int minute,
  }) async {
    await scheduleRecurringNotification(
      id: transactionName.hashCode,
      title: '🔄 Recurring Transaction',
      body: 'Don\'t forget to add: $transactionName',
      hour: hour,
      minute: minute,
    );
  }

  /// Daily summary notification
  Future<void> scheduleDailySummary(
      {required int hour, required int minute}) async {
    await scheduleRecurringNotification(
      id: 999,
      title: '📊 Daily Summary',
      body: 'Check your spending today',
      hour: hour,
      minute: minute,
    );
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
