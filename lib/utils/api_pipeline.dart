import 'dart:convert';
import 'dart:io';

import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'other.dart';

Future<dynamic> makeAPIRequest({
  required Uri url,
  required String method,
  Map<String, String>? headers,
  Map<String, dynamic>? body,
  bool requiresAuth = true,
}) async {
  try {
    // Prepare headers
    final preparedHeaders = <String, String>{
      'Content-Type': 'application/json',
      ...?headers,
    };

    // Add authorization if required
    if (requiresAuth) {
      final prefs = await SharedPreferences.getInstance();
      final storedToken = prefs.getString('session_token');
      if (storedToken == null) {
        throw Exception('No session token available');
      }
      preparedHeaders['Authorization'] = storedToken;
    }

    // Perform the request based on method
    http.Response response;
    switch (method.toUpperCase()) {
      case 'GET':
        response = await http.get(url, headers: preparedHeaders);
        break;
      case 'POST':
        response = await http.post(
          url,
          headers: preparedHeaders,
          body: body != null ? json.encode(body) : null,
        );
        break;
      case 'PUT':
        response = await http.put(
          url,
          headers: preparedHeaders,
          body: body != null ? json.encode(body) : null,
        );
        break;
      case 'PATCH':
        response = await http.patch(
          url,
          headers: preparedHeaders,
          body: body != null ? json.encode(body) : null,
        );
        break;
      default:
        throw UnsupportedError('Unsupported HTTP method: $method');
    }

    // Handle response
    if (response.statusCode == 204) {
      return null;
    } else if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['detail'] ?? 'API request failed');
    }
  } catch (e) {
    print('API Error: $e');
    rethrow;
  }
}

Future<http.MultipartFile> webfileToHTTP(
  WebAttachment webFile,
  String field,
  String filename,
) async {
  return http.MultipartFile.fromBytes(
    field,
    webFile.bytes,
    filename: filename,
  );
}

Future<http.MultipartFile> fileToHTTP(
  File file,
  String field,
  String filename,
) async {
  return http.MultipartFile.fromPath(
    field,
    file.path,
    filename: filename,
    contentType: MediaType('image', 'jpeg'),
  );
}

// Multipart file upload method
Future<dynamic> uploadImage({
  required Uri url,
  required Map<String, String> fields,
  File? fileToUpload,
  WebAttachment? fileWeb,
  String fileFieldName = 'file',
}) async {
  try {
    const uuid = Uuid();
    var request = http.MultipartRequest('PUT', url);

    // Add session token
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('session_token');
    request.headers['Authorization'] = storedToken!;

    // Add text fields
    request.fields.addAll(fields);

    // Add file if present
    if (fileToUpload != null) {
      request.files.add(
        await fileToHTTP(
          fileToUpload,
          fileFieldName,
          getRandomizedName(fileToUpload.path, uuid, keepBaseName: false),
        ),
      );
    } else if (fileWeb != null) {
      request.files.add(
        await webfileToHTTP(
          fileWeb,
          fileFieldName,
          getRandomizedName(fileWeb.name, uuid, keepBaseName: false),
        ),
      );
    }

    // Send the request
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['error'] ?? 'File upload failed');
    }
  } catch (e) {
    print('File Upload Error: $e');
    rethrow;
  }
}
