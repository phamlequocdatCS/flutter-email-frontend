import 'dart:io';

import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';
import '../constants.dart';
import '../utils/other.dart';
import '../utils/api_pipeline.dart';

class EmailComposeProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  bool _isSuccess = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSuccess => _isSuccess;

  Future<void> sendEmail({
    required List<String> recipients,
    List<String>? ccRecipients,
    List<String>? bccRecipients,
    required String subject,
    required String body,
    List<dynamic>? attachments,
  }) async {
    // Reset state completely
    reset();

    try {
      // Prepare multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(API_Endpoints.EMAIL_SEND.value),
      );

      processEmailFields(
        request,
        recipients,
        ccRecipients,
        bccRecipients,
        subject,
        body,
      );

      var uuid = const Uuid();

      // Add attachments
      if (attachments != null) {
        for (var file in attachments) {
          final filename = getRandomizedName(file.name, uuid);
          if (kIsWeb && file is WebAttachment) {
            // For web, use MultipartFile.fromBytes
            request.files.add(
              await webfileToHTTP(
                file,
                'attachments',
                filename,
              ),
            );
          } else if (!kIsWeb && file is File) {
            // Existing file path logic for mobile/desktop
            request.files.add(await fileToHTTP(file, 'attachments', filename));
          }
        }
      }

      // Add authorization header
      final prefs = await SharedPreferences.getInstance();
      final storedToken = prefs.getString('session_token');
      request.headers['Authorization'] = storedToken!;

      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _isSuccess = true;
        _isLoading = false;
        notifyListeners();
        return;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Email sending failed');
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      _isSuccess = false;
      notifyListeners();
      rethrow;
    }
  }

  void processEmailFields(
    http.MultipartRequest request,
    List<String> recipients,
    List<String>? ccRecipients,
    List<String>? bccRecipients,
    String subject,
    String body,
  ) {
    request.fields['recipients'] = json.encode(recipients);
    if (ccRecipients != null) {
      request.fields['cc'] = json.encode(ccRecipients);
    }
    if (bccRecipients != null) {
      request.fields['bcc'] = json.encode(bccRecipients);
    }
    request.fields['subject'] = subject;
    request.fields['body'] = body;
  }

  void markNavigatedAfterSuccess() {
    _isSuccess = false;
    notifyListeners();
  }

  // Reset the state for a new email composition
  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();
  }
}
