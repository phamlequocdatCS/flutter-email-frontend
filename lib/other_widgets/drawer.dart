import 'package:flutter/material.dart';

ListTile buildDrawerItem(
  IconData icon,
  String title,
  String route,
  BuildContext context,
  Color textColor,
  Color iconColor,
  Object? arguments, {
  isReplacement = false,
}) {
  return ListTile(
    leading: Icon(icon, color: iconColor),
    title: Text(title, style: TextStyle(color: textColor)),
    onTap: () {
      if (isReplacement) {
        Navigator.pushReplacementNamed(context, route, arguments: arguments);
      } else {
        Navigator.pushNamed(context, route, arguments: arguments);
      }
    },
  );
}
