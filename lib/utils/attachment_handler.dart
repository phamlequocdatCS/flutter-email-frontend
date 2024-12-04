import 'dart:typed_data';
import 'dart:io' show File, Platform;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';

import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

import '../constants.dart';
import '../data_classes.dart';
import '../other_widgets/video_player.dart';

class AttachmentHandler {
  // Method to get appropriate icon based on file type
  static Widget getAttachmentIcon(EmailAttachment attachment) {
    final extension = attachment.filename.split('.').last.toLowerCase();

    switch (extension) {
      case 'pdf':
        return const Icon(Icons.picture_as_pdf, color: Colors.red);
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return const Icon(Icons.image, color: Colors.blue);
      case 'doc':
      case 'docx':
        return const Icon(Icons.document_scanner, color: Colors.blue);
      case 'xls':
      case 'xlsx':
        return const Icon(Icons.table_chart, color: Colors.green);
      case 'mp4':
      case 'webm':
        return const Icon(Icons.video_library, color: Colors.green);
      default:
        return const Icon(Icons.attachment);
    }
  }

  // Cross-platform preview method
  static Future<void> previewAttachment(
      BuildContext context, EmailAttachment attachment) async {
    try {
      final fullUrl = getAttachmentURL(attachment.file_url);
      final extension = attachment.filename.split('.').last.toLowerCase();

      if (['jpg', 'jpeg', 'png', 'gif'].contains(extension)) {
        await _previewImage(context, fullUrl, attachment.filename);
      } else if (extension == 'pdf') {
        await _previewPDF(context, fullUrl, attachment.filename);
      } else if (['mp4', 'webm'].contains(extension)) {
        await _previewVideo(context, fullUrl, attachment.filename);
      } else if (extension == 'txt') {
        await _previewTextFile(context, fullUrl, attachment.filename);
      } else {
        _showUnsupportedPreviewDialog(context, attachment.filename);
      }
    } catch (e) {
      _showErrorSnackbar(context, 'Failed to preview attachment: $e');
    }
  }

  // Image preview for both web and mobile
  static Future<void> _previewImage(
      BuildContext context, String fullUrl, String filename) async {
    if (kIsWeb) {
      // Web image preview
      showDialog(
        context: context,
        builder: (context) => Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: Text(filename),
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              Image.network(
                fullUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const CircularProgressIndicator();
                },
              ),
            ],
          ),
        ),
      );
    } else {
      // Mobile image preview
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: Text(filename)),
            body: PhotoView(
              imageProvider: NetworkImage(fullUrl),
              loadingBuilder: (context, event) => const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        ),
      );
    }
  }

  // PDF preview for both web and mobile
  static Future<void> _previewPDF(
      BuildContext context, String fullUrl, String filename) async {
    if (kIsWeb) {
      // Open PDF in new tab for web
      if (await canLaunchUrl(Uri.parse(fullUrl))) {
        await launchUrl(Uri.parse(fullUrl));
      } else {
        throw 'Could not launch $fullUrl';
      }
    } else {
      // Download the file first
      String filePath = await _downloadTempFile(fullUrl, filename);

      // Then push the new route
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFView(
            filePath: filePath,
            enableSwipe: true,
            swipeHorizontal: true,
            autoSpacing: false,
            pageFling: true,
          ),
        ),
      );
    }
  }

  // Add video preview method
  static Future<void> _previewVideo(
      BuildContext context, String fullUrl, String filename) async {
    if (kIsWeb) {
      // For web, open video in new tab
      if (await canLaunchUrl(Uri.parse(fullUrl))) {
        await launchUrl(Uri.parse(fullUrl));
      } else {
        throw 'Could not launch $fullUrl';
      }
    } else {
      // For mobile, use the video_player package
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              VideoPreviewScreen(fullUrl: fullUrl, filename: filename),
        ),
      );
    }
  }

  // Add text file preview method
  static Future<void> _previewTextFile(
      BuildContext context, String fullUrl, String filename) async {
    try {
      if (kIsWeb) {
        // Web-specific handling
        await _previewTextFileForWeb(context, fullUrl, filename);
      } else {
        // Existing mobile/desktop implementation
        final tempFilePath = await _downloadTempFile(fullUrl, filename);
        final File file = File(tempFilePath);
        final String fileContents = await file.readAsString();

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: Text(filename)),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  fileContents,
                  style: const TextStyle(fontSize: 16.0),
                ),
              ),
            ),
          ),
        );
      }
    } catch (e) {
      _showErrorSnackbar(context, 'Failed to preview text file: $e');
    }
  }

  static Future<void> _previewTextFileForWeb(
      BuildContext context, String fullUrl, String filename) async {
    try {
      // Fetch file contents directly using http package
      final response = await http.get(Uri.parse(fullUrl));

      if (response.statusCode == 200) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: Text(filename)),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  response.body,
                  style: const TextStyle(fontSize: 16.0),
                ),
              ),
            ),
          ),
        );
      } else {
        throw Exception('Failed to load file');
      }
    } catch (e) {
      _showErrorSnackbar(context, 'Failed to preview text file on web: $e');
    }
  }

  // Download method for both web and mobile
  static Future<void> downloadAttachment(
    BuildContext context,
    EmailAttachment attachment,
  ) async {
    try {
      final fullUrl = getAttachmentURL(attachment.file_url);

      if (kIsWeb) {
        // Web download
        await _downloadForWeb(fullUrl, attachment.filename);
      } else {
        // Mobile download
        await _downloadForMobile(context, fullUrl, attachment.filename);
      }
    } catch (e) {
      _showErrorSnackbar(context, 'Download failed: $e');
    }
  }

  // Web download method
  static Future<void> _downloadForWeb(String url, String filename) async {
    try {
      // Fetch the file data
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Convert response body to Uint8List
        final Uint8List bytes = Uint8List.fromList(response.bodyBytes);

        // Create a Blob from the bytes
        final blob = html.Blob([bytes]);

        // Create a download link
        final anchor =
            html.AnchorElement(href: html.Url.createObjectUrlFromBlob(blob))
              ..setAttribute('download', filename)
              ..style.display = 'none';

        // Append to body, click, and remove
        html.document.body?.append(anchor);
        anchor.click();
        html.document.body?.children.remove(anchor);

        // Revoke the object URL to free up memory
        html.Url.revokeObjectUrl(anchor.href!);
      } else {
        throw Exception('Download failed');
      }
    } catch (e) {
      print('Web download error: $e');
    }
  }

  // Mobile download method
  static Future<void> _downloadForMobile(
      BuildContext context, String fullUrl, String filename) async {
    // Request storage permissions for Android
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('Storage permission denied');
      }
    }

    // Use dio for downloading
    final dio = Dio();
    final downloadsDirectory = await getDownloadsDirectory();
    final filePath = '${downloadsDirectory?.path}/$filename';

    await dio.download(
      fullUrl,
      filePath,
      onReceiveProgress: (received, total) {
        // Optional: Show download progress
        if (total != -1) {
          print("${(received / total * 100).toStringAsFixed(0)}%");
        }
      },
    );

    // Notify user of successful download
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Downloaded: $filename')),
    );

    // Open the file after download
    await OpenFile.open(filePath);
  }

  // Helper method to download file to a temporary location
  static Future<String> _downloadTempFile(String url, String filename) async {
    try {
      final dio = Dio();
      final tempDir = await getTemporaryDirectory();
      final tempFilePath = '${tempDir.path}/$filename';

      await dio.download(url, tempFilePath);
      return tempFilePath;
    } catch (e) {
      print('Error downloading temp file: $e');
      rethrow;
    }
  }

  // Utility method to show unsupported preview dialog
  static void _showUnsupportedPreviewDialog(
      BuildContext context, String filename) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('File Preview'),
        content: Text('Preview not supported for $filename'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  // Utility method to show error snackbar
  static void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
