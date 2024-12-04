import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

String formatTimeSent(
  DateTime timeSent,
  BuildContext context, {
  bool forceIncludeFull = false,
}) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));
  final yesterday = today.subtract(const Duration(days: 1));

  String result = "";

  if (timeSent.isAfter(yesterday) && timeSent.isBefore(today)) {
    result += AppLocalizations.of(context)!.yesterday;
    if (!forceIncludeFull) return result;
    result += ", ";
  }

  if (forceIncludeFull ||
      (timeSent.isAfter(today) && timeSent.isBefore(tomorrow))) {
    result += DateFormat('HH:mm').format(timeSent.toLocal());
    if (!forceIncludeFull) return result;
    result += ", ";
  }

  final difference = now.difference(timeSent).inDays;
  if (difference >= 365 || forceIncludeFull) {
    result += DateFormat('MM/dd/yyyy').format(timeSent.toLocal());
  } else {
    result += DateFormat('MM/dd').format(timeSent.toLocal());
  }

  return result;
}
