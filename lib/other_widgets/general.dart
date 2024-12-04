import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../constants.dart';
import '../data_classes.dart';

TextField getTextField(
  TextEditingController controller,
  String labelText, {
  int? maxLines,
}) {
  return TextField(
    controller: controller,
    maxLines: maxLines,
    decoration: InputDecoration(
      labelText: labelText,
      border: const OutlineInputBorder(),
    ),
  );
}

TextField getTextFieldHint(
  TextEditingController controller,
  String labelText,
  String hintText, {
  int? maxLines,
}) {
  return TextField(
    controller: controller,
    maxLines: maxLines,
    decoration: InputDecoration(
      labelText: labelText,
      hintText: hintText,
      border: const OutlineInputBorder(),
    ),
  );
}

void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

ImageProvider<Object> getImageFromAccount(Account currentAccount) {
  return CachedNetworkImageProvider(
    getUserProfileImageURL(
      currentAccount.profile_picture,
    ),
  );
}

ElevatedButton getSaveButton(
  BuildContext context,
  VoidCallback onPressed,
  String displayText,
) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    ),
    child: Text(displayText),
  );
}

ElevatedButton getButtonCondition(
  BuildContext context,
  VoidCallback onPressed,
  bool condition,
  String displayTrue,
  String displayFalse,
) {
  return ElevatedButton(
    onPressed: onPressed,
    child: Text(condition ? displayTrue : displayFalse),
  );
}

const centerCircleProgress = Center(child: CircularProgressIndicator());

enum LabelColorPreset {
  red(Color(0xFFFF5252)),
  green(Color(0xFF4CAF50)),
  blue(Color(0xFF2196F3)),
  purple(Color(0xFF9C27B0)),
  orange(Color(0xFFFF9800)),
  grey(Color(0xFF9E9E9E));

  final Color color;
  const LabelColorPreset(this.color);
}

Color getTextColorForChip(Color chipColor) {
  double luminance = (0.299 * chipColor.red +
          0.587 * chipColor.green +
          0.114 * chipColor.blue) /
      255;
  return luminance > 0.5 ? Colors.black : Colors.white;
}
