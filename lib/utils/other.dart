import 'dart:typed_data';

import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';

class WebAttachment {
  final String name;
  final Uint8List bytes;

  WebAttachment({required this.name, required this.bytes});

  factory WebAttachment.fromPlatformFile(PlatformFile platformFile) {
    return WebAttachment(name: platformFile.name, bytes: platformFile.bytes!);
  }
}

String getRandomizedName(
  String filename,
  Uuid uuid, {
  bool keepBaseName = true,
}) {
  final split = filename.split('.');
  String extension = split.last;
  final String randomizedFilename;
  if (keepBaseName) {
    String baseName = split.first;
    randomizedFilename = '$baseName-${uuid.v4()}.$extension';
  } else {
    randomizedFilename = '${uuid.v4()}.$extension';
  }
  return randomizedFilename;
}
