import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';


class LocalNotificationService extends GetxService {
  final String channelId = "default_channel";
  final String channelName = "DefaultNotifications";
  final String channelDescription = "Default App Notifications";
  final String notificationIconPath = "mipmap/ic_launcher";

  FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void onInit() {
    super.onInit();
    _initializeLocalNotifications();
    _createNotificationChannel();
  }

  Future _onSelectionNotification(NotificationResponse payload) async {
    if (payload != null) OpenFilex.open(payload.payload);
  }

  void _initializeLocalNotifications() {
    var initializationSettingsAndroid =
        AndroidInitializationSettings(notificationIconPath);
    var initializationSettingIOS = DarwinInitializationSettings();
    var initializationSetting = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingIOS,
    );

    _flutterLocalNotificationsPlugin.initialize(
      initializationSetting,
      onDidReceiveNotificationResponse: _onSelectionNotification,
    );
  }

  Future<void> _createNotificationChannel() async {
    var androidNotificationChannel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDescription,
      importance: Importance.max,
      enableVibration: true,
    );
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidNotificationChannel);
  }

  Future<void> showLocal(
    String title,
    String message, {
    Map payloadMsg,
    int notificationId = 0,
  }) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      showWhen: false,
    );
    var iOSPlatformChannelSpecifics = DarwinNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    await _flutterLocalNotificationsPlugin.show(
      notificationId,
      title,
      message,
      platformChannelSpecifics,
      payload: _getPayLoadString(payloadMsg),
    );
  }

  _getPayLoadString(Map payloadMsg) {
    if (payloadMsg == null) return "default";
    return payloadMsg['path'];
  }

  Future<void> navigateUser(String notificationType, String visitId) async {}
}
