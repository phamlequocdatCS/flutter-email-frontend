import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../constants.dart';
import '../data_classes.dart';
import 'email_provider.dart';
import 'notification_provider.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  final EmailsProvider _emailsProvider;
  final UserNotificationProvider _notificationProvider;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;

  WebSocketService(this._emailsProvider, this._notificationProvider);

  Future<void> connect() async {
    final sessionToken = await _getSessionToken();
    if (sessionToken == null) {
      print(
          'No session token found. Unable to establish WebSocket connection.');
      return;
    }

    _reconnectAttempts++;
    try {
      _initializeWebSocket(sessionToken);
      _reconnectAttempts = 0; // Reset reconnect attempts on success
    } catch (e) {
      print('WebSocket connection failed: $e');
      _attemptReconnect();
    }
  }

  Future<String?> _getSessionToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('session_token');
  }

  void _initializeWebSocket(String sessionToken) {
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://$ROOT/ws/emails/?token=$sessionToken'),
    );

    print('WebSocket connection established');
    _channel!.stream.listen(
      _onMessageReceived,
      onDone: () {
        print('WebSocket connection closed');
        _attemptReconnect();
      },
      onError: (error) {
        print('WebSocket error: $error');
        _attemptReconnect();
      },
    );
  }

  void _onMessageReceived(dynamic message) {
    try {
      final data = json.decode(message);
      print('Received and decoded WebSocket message: $data');
      _handleWebSocketMessage(data);
    } catch (e) {
      print('Error decoding WebSocket message: $e');
    }
  }

  void _handleWebSocketMessage(Map<String, dynamic> data) {
    try {
      switch (data['type']) {
        case 'email_notification':
          _processEmailNotification(data);
          break;
        case 'email_update':
          _processEmailUpdate(data);
          break;
        default:
          print('Unknown message type: ${data['type']}');
      }
    } catch (e) {
      print('Error handling WebSocket message: $e');
    }
  }

  void _processEmailNotification(Map<String, dynamic> data) {
    print('Processing email notification');
    final newEmail = Email.fromJson(data['email']);
    final mailbox = _determineMailboxForEmail(newEmail) ?? 'inbox';
    _emailsProvider.addNewEmailToCache(newEmail, mailbox: mailbox);

    final newNotification = UserNotification.fromJson(data['notification']);
    _notificationProvider.addNotification(newNotification);
  }

  void _processEmailUpdate(Map<String, dynamic> data) {
    print('Processing email update');
    final updatedEmail = Email.fromJson(data['email']);
    _emailsProvider.updateEmailInCache(updatedEmail);
  }

  String? _determineMailboxForEmail(Email email) {
    if (email.is_trashed) return 'trash';
    if (email.is_starred) return 'starred';
    if (email.is_draft) return 'drafts';
    return 'inbox'; // Default mailbox
  }

  void _attemptReconnect() {
    _reconnectTimer?.cancel();

    if (_reconnectAttempts > _maxReconnectAttempts) {
      print('Max reconnect attempts reached. Stopping reconnection.');
      return;
    }

    final retryDuration = Duration(seconds: pow(2, _reconnectAttempts).toInt());
    print('Attempting to reconnect in ${retryDuration.inSeconds} seconds');

    _reconnectTimer = Timer(retryDuration, connect);
  }

  void dispose() {
    _reconnectTimer?.cancel();
    _channel?.sink.close();
  }
}
