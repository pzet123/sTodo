import 'package:awesome_notifications/awesome_notifications.dart';

Future<void> createQuestTrackingNotification({required questName, required nextTask}) async {
  await AwesomeNotifications().createNotification(
      content: NotificationContent(id: 0,
          channelKey: "Quest Tracking Channel",
          title: "${Emojis.tool_crossed_swords} Current Quest: $questName",
          body: nextTask,
          notificationLayout: NotificationLayout.Default
      )
  );
}