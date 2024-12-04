import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../data_classes.dart';

class NotifsProvider extends ChangeNotifier {
  List<NotificationData> _notifs = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  // Getters
  List<NotificationData> get notifs => _notifs;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;

  Future<void> fetchNotifs() async {
    try {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
      notifyListeners();

      String jsonString = await rootBundle.loadString('mock.json');
      Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      List<dynamic> notifsJson = jsonMap['notifications'];

      _notifs = notifsJson
          .map(
            (json) => NotificationData.fromJson(json),
          )
          .toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _hasError = true;
      _errorMessage = 'Error fetching notifications: $e';
      print(_errorMessage);
      notifyListeners();
    }
  }
}
