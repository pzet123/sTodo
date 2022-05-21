import 'package:flutter_local_notifications/flutter_local_notifications.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('res_app_icon');
final IOSInitializationSettings initializationSettingsIOS =
    IOSInitializationSettings();
final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails('your channel id', 'your channel name',
        channelDescription: 'your channel description',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker');
const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

Future<void> initialiseNotifications() async {
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (_) {});
}

Future<void> createQuestTrackingNotification(
    {required questName, required nextTask}) async {
  await flutterLocalNotificationsPlugin.show(0, questName,
      "Next Task: ${nextTask.getTaskDescription()}", platformChannelSpecifics,
      payload: "");
}
