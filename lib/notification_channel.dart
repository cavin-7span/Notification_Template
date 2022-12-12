import 'dart:developer';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notification_template/constant.dart';

class NotificationHelper {
  //singleton pattern to ensure only one instance is created
  static final NotificationHelper _instance = NotificationHelper._internal();
  factory NotificationHelper() => _instance;
  NotificationHelper._internal();

  //flutter local notification plugin
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  late AndroidNotificationChannel channel;

  tokenInit() async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    log("fcmToken: $fcmToken");
    final fcmWebToken = await FirebaseMessaging.instance.getToken(
      vapidKey: webNotificationKey,
    );
    debugPrint("fcmToken web: $fcmWebToken");
  }

  Future<void> setupFlutterNotifications() async {
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.high,
    );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    if (Platform.isIOS) {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  getMessageStream() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log("on foreground message handling");
      NotificationToast.showFlutterNotification(message, channel);
    });
  }
}

class NotificationInitialization {
  static final NotificationInitialization _instance =
      NotificationInitialization._internal();
  factory NotificationInitialization() => _instance;
  NotificationInitialization._internal();

  static void startNotificationService() async {
    final NotificationHelper notificationHelper = NotificationHelper();
    if (!kIsWeb) {
      // await Firebase.initializeApp(
      //   options: const FirebaseOptions(
      //     apiKey: "AIzaSyB_WB7Wja1c3KQIMwb8ERres840PdEi-Ng",
      //     appId: "1:595028006349:web:d702ff566628aef278a084",
      //     messagingSenderId: "595028006349",
      //     projectId: "notification-template-d55fc",
      //   ),
      // );
      await Firebase.initializeApp();
      await notificationHelper.tokenInit();
      await notificationHelper.setupFlutterNotifications();
      notificationHelper.getMessageStream();
    } else {}
  }
}

class NotificationToast {
  static void showFlutterNotification(
      RemoteMessage message, AndroidNotificationChannel channel) {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null && !kIsWeb) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: 'launch_background',
            priority: Priority.high,
            importance: Importance.high,
          ),
        ),
      );
    }
  }
}
