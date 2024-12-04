import 'package:flutter/material.dart';

import '../data_classes.dart';

ListTile getNotifTile(
  NotificationData notif,
  GestureTapCallback onTap,
  BuildContext context,
) {
  return ListTile(
    leading: const Icon(Icons.notifications, color: Colors.blue),
    title: Text(notif.notifTitle),
    subtitle: Text(notif.notifSubtitle),
    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    onTap: onTap,
  );
}
