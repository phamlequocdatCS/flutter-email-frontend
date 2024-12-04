import 'package:flutter/material.dart';

List<String> parseSeparatedFields(
  TextEditingController controller, {
  String delimiter = ",",
}) {
  return controller.text
      .split(delimiter)
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
}
