import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../data_classes.dart';
import '../utils/attachment_handler.dart';
import '../other_widgets/email_detailed.dart';
import '../state_management/email_provider.dart';
import '../state_management/label_provider.dart';
import 'gmail_compose_email_screen.dart';

class GmailEmailDetailScreen extends StatefulWidget {
  final Email email;
  final String? mailbox;

  const GmailEmailDetailScreen({super.key, required this.email, this.mailbox});

  @override
  State<GmailEmailDetailScreen> createState() => _GmailEmailDetailScreenState();
}

class _GmailEmailDetailScreenState extends State<GmailEmailDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch emails when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LabelProvider>(context, listen: false).fetchLabels();
    });
  }

  void _replyEmail() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EmailComposeScreen(
          replyTo: widget.email,
        ),
      ),
    );
  }

  void _forwardEmail() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EmailComposeScreen(
          forwardFrom: widget.email,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quillController = quill.QuillController(
      document: quill.Document.fromJson(jsonDecode(widget.email.body)),
      selection: const TextSelection.collapsed(offset: 0),
    );
    final emailsProvider = Provider.of<EmailsProvider>(context);
    final labelsProvider = Provider.of<LabelProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.mailDetail),
        actions: [
          // Mark as Read/Unread
          getReadEmailButton(emailsProvider),
          // Star/Unstar
          getStarEmailButton(emailsProvider),
          // Move to Trash
          getTrashEmailButton(emailsProvider),
          getLabelManagementDropdown(emailsProvider, labelsProvider),
          IconButton(
            icon: const Icon(Icons.reply),
            onPressed: _replyEmail,
          ),
          IconButton(
            icon: const Icon(Icons.forward),
            onPressed: _forwardEmail,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Metadata section
            buildMetadataSection(context, widget.email),
            const SizedBox(height: 10),
            const Divider(color: Colors.grey),
            const SizedBox(height: 10),
            // Email body
            getQuillViewer(quillController),
            // Attachments section
            if (widget.email.attachments.isNotEmpty) _buildAttachmentsSection(),
          ],
        ),
      ),
    );
  }

  IconButton getReadEmailButton(EmailsProvider emailsProvider) {
    return IconButton(
      icon: Icon(
        widget.email.is_read ? Icons.mark_email_unread : Icons.mark_email_read,
      ),
      onPressed: () {
        emailsProvider.performEmailAction(
          widget.email,
          EmailAction.markRead,
          mailbox: widget.mailbox,
        );
        print("is read?");
        setState(() {});
      },
    );
  }

  IconButton getStarEmailButton(EmailsProvider emailsProvider) {
    return IconButton(
      icon: Icon(
        widget.email.is_starred ? Icons.star : Icons.star_border,
      ),
      onPressed: () => emailsProvider.performEmailAction(
        widget.email,
        EmailAction.star,
      ),
    );
  }

  IconButton getTrashEmailButton(EmailsProvider emailsProvider) {
    return IconButton(
      icon: const Icon(Icons.delete),
      onPressed: () => emailsProvider.performEmailAction(
        widget.email,
        EmailAction.moveToTrash,
        mailbox: widget.mailbox,
      ),
    );
  }

  PopupMenuButton<EmailLabel> getLabelManagementDropdown(
    EmailsProvider emailsProvider,
    LabelProvider labelsProvider,
  ) {
    return PopupMenuButton<EmailLabel>(
      icon: const Icon(Icons.label),
      onSelected: (EmailLabel label) {
        // Toggle label
        emailsProvider.updateEmailLabels(
          email: widget.email,
          label: label,
        );
      },
      itemBuilder: (BuildContext context) => labelsProvider.labels.map(
        (EmailLabel label) {
          bool isLabeled = widget.email.labels.contains(label);
          return PopupMenuItem<EmailLabel>(
            value: label,
            child: Row(
              children: [
                Checkbox(
                  value: isLabeled,
                  onChanged: (bool? newValue) {
                    emailsProvider.updateEmailLabels(
                      email: widget.email,
                      label: label,
                    );
                    Navigator.of(context).pop();
                  },
                ),
                Text(label.displayName),
              ],
            ),
          );
        },
      ).toList(),
    );
  }

  Expanded getQuillViewer(quill.QuillController quillController) {
    return Expanded(
      child: quill.QuillEditor.basic(
        controller: quillController,
        scrollController: ScrollController(),
        configurations: const quill.QuillEditorConfigurations(
          scrollable: true,
          expands: false,
          showCursor: false,
          padding: EdgeInsets.all(16),
          autoFocus: false,
        ),
        focusNode: FocusNode(
          canRequestFocus: false,
        ),
      ),
    );
  }

  Widget _buildAttachmentsSection() {
    return ExpansionTile(
      title: Text('Attachments (${widget.email.attachments.length})'),
      children: widget.email.attachments.map((attachment) {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: InkWell(
            onTap: () {
              // Preview attachment when tile is tapped
              AttachmentHandler.previewAttachment(context, attachment);
            },
            child: ListTile(
              leading: AttachmentHandler.getAttachmentIcon(attachment),
              title: Text(attachment.filename),
              trailing: IconButton(
                icon: const Icon(Icons.download),
                onPressed: () {
                  // Download attachment when download button is pressed
                  AttachmentHandler.downloadAttachment(context, attachment);
                },
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
