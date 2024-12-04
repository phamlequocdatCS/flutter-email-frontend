import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'general.dart';
import 'email_helper.dart';
import '../data_classes.dart';
import '../state_management/account_provider.dart';

Widget buildMetadataSection(BuildContext context, Email email, {bool isLargeTitle = true}) {
  final accountProvider = Provider.of<AccountProvider>(
    context,
    listen: false,
  );
  bool isFromMe = email.sender_id == accountProvider.currentAccount!.userID;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      getSubjectDetail(context, email, isLargeTitle),
      const SizedBox(height: 8),
      getSenderDetail(context, isFromMe, email),
      const SizedBox(height: 8),
      getRecipientsDetail(context, isFromMe, email),
      const SizedBox(height: 8),
      getSentAtDetail(context, email),
      if (email.labels.isNotEmpty) const SizedBox(height: 8),
      if (email.labels.isNotEmpty) getLabelsDisplay(email),
    ],
  );
}

Wrap getLabelsDisplay(Email email) {
  return Wrap(
    spacing: 8,
    children: email.labels
        .map(
          (label) => Chip(
            label: Text(
              label.displayName,
              style: TextStyle(color: getTextColorForChip(label.color)),
            ),
            backgroundColor: label.color,
          ),
        )
        .toList(),
  );
}

Text getSubjectDetail(BuildContext context, Email email, bool isLargeTitle) {
  return Text(
    '${AppLocalizations.of(context)!.emailSubject}: ${email.subject}',
    style: isLargeTitle? Theme.of(context).textTheme.titleLarge!.copyWith(
          fontWeight: FontWeight.bold,
        ) : Theme.of(context).textTheme.labelLarge!.copyWith(
          fontWeight: FontWeight.bold,
        ),
  );
}

Row getSenderDetail(BuildContext context, bool isFromMe, Email email) {
  String senderText =
      isFromMe ? AppLocalizations.of(context)!.me : email.sender;
  return Row(
    children: [
      const Icon(Icons.person, color: Colors.grey),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          '${AppLocalizations.of(context)!.emailFromCap}: $senderText',
          style: Theme.of(context).textTheme.labelMedium!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
      ),
    ],
  );
}

Column getRecipientsDetail(BuildContext context, bool isFromMe, Email email) {
  Color textColor = Theme.of(context).colorScheme.onSurface;
  TextStyle recipientStyle = Theme.of(context).textTheme.labelMedium!.copyWith(
        color: textColor,
      );

  // Helper method to create a Row with an icon and text
  Widget buildRecipientRow(
    IconData icon,
    String label,
    List<String> recipients,
  ) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$label ${recipients.join(", ")}',
            style: recipientStyle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  return Column(
    children: [
      buildRecipientRow(
        Icons.people,
        '${AppLocalizations.of(context)!.emailToCap}:',
        email.recipients,
      ),
      const SizedBox(height: 8),
      buildRecipientRow(Icons.source, 'CC:', email.cc),
      if (isFromMe)
        buildRecipientRow(
          Icons.hide_source,
          'BCC:',
          email.bcc,
        ),
    ],
  );
}

Row getSentAtDetail(BuildContext context, Email email) {
  return Row(
    children: [
      const Icon(Icons.access_time, color: Colors.grey),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          formatTimeSent(
            email.sent_at,
            context,
            forceIncludeFull: true,
          ),
          style: Theme.of(context).textTheme.labelMedium!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
      ),
    ],
  );
}
