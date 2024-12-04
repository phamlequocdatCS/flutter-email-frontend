import 'package:flutter/material.dart';

import '../state_management/notification_provider.dart';

Positioned getUnreadNotifBubble(
  UserNotificationProvider notificationProvider,
) {
  return Positioned(
    left: 30,
    child: Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(6),
      ),
      constraints: const BoxConstraints(
        minWidth: 18,
        minHeight: 18,
      ),
      child: Text(
        '${notificationProvider.unreadNotificationsCount}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    ),
  );
}
