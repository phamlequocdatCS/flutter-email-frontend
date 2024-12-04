import 'package:flutter/foundation.dart';

import '../constants.dart';
import '../data_classes.dart';
import '../utils/api_pipeline.dart';

class UserNotificationProvider with ChangeNotifier {
  List<UserNotification> _notifications = [];
  bool _enableNotifications = true;

  List<UserNotification> get notifications => _notifications;
  bool get enableNotifications => _enableNotifications;

  // Get unread notifications count
  int get unreadNotificationsCount =>
      _notifications.where((n) => !n.isRead).length;

  void setNotificationStatus(bool status) {
    _enableNotifications = status;
    notifyListeners();
  }

  void addNotification(UserNotification newNotification) {
    _notifications.insert(0, newNotification);
    notifyListeners();
  }

  Future<void> fetchNotifications() async {
    try {
      final response = await makeAPIRequest(
        url: Uri.parse(API_Endpoints.NOTIFICATIONS.value),
        method: 'GET',
      );

      _notifications = [];

      for (dynamic json in (response as List)) {
        // print(json);
        _notifications.add(UserNotification.fromJson(json));
        // print("\n");
      }

      notifyListeners();
    } catch (e) {
      print('Failed to fetch notifications: $e');
    }
  }

  Future<void> updateNotificationReadStatus(
    int notificationId,
    bool isRead,
  ) async {
    try {
      await makeAPIRequest(
        url: Uri.parse('${API_Endpoints.NOTIFICATIONS.value}$notificationId/'),
        method: 'PATCH',
        body: {'is_read': isRead},
      );
      // Update local list
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index].isRead = isRead;
        notifyListeners();
      }
    } catch (e) {
      print('Failed to update notification read status: $e');
    }
  }

  Future<void> markNotificationRead(int notificationId) async {
    try {
      await makeAPIRequest(
        url: Uri.parse('${API_Endpoints.NOTIFICATIONS.value}$notificationId/'),
        method: 'PATCH',
        body: {'is_read': true},
      );
      // Update local list
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index].isRead = true;
        notifyListeners();
      }
    } catch (e) {
      print('Failed to mark notification read: $e');
    }
  }
}

