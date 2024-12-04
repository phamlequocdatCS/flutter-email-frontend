import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'gmail_base_screen.dart';
import '../constants.dart';
import '../data_classes.dart';
import '../other_widgets/email.dart';
import '../other_widgets/searcher.dart';
import '../state_management/label_provider.dart';
import '../state_management/email_provider.dart';

class MailFolderScreen extends StatefulWidget {
  final String mailbox;
  final String title;
  final String boxEmptyMessage;

  const MailFolderScreen({
    super.key,
    required this.mailbox,
    required this.title,
    required this.boxEmptyMessage,
  });

  @override
  State<MailFolderScreen> createState() => _MailFolderScreenState();
}

class _MailFolderScreenState extends State<MailFolderScreen> {
  bool _isDetailedView = false;
  final Map<int, OtherUserProfile> profileCache = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EmailsProvider>(context, listen: false).refreshEmails(
        mailbox: widget.mailbox,
      );
      Provider.of<LabelProvider>(context, listen: false).fetchLabels();
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget viewToggleWidget = Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton.icon(
        onPressed: () {
          setState(() {
            _isDetailedView = !_isDetailedView;
          });
        },
        icon: Icon(
          _isDetailedView ? Icons.view_compact : Icons.view_agenda,
        ),
        label: Text(
          _isDetailedView
              ? AppLocalizations.of(context)!.compactView
              : AppLocalizations.of(context)!.detailedView,
        ),
      ),
    );
    return GmailBaseScreen(
      title: widget.title,
      appBarWidget: getUltimateEmailBar(viewToggleWidget, widget.mailbox),
      body: Consumer<EmailsProvider>(
        builder: (context, emailsProvider, child) => getMailFolderBuilder(
          context,
          emailsProvider,
          child,
          _isDetailedView,
          profileCache,
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, MailRoutes.COMPOSE.value);
        },
        label: Text(AppLocalizations.of(context)!.composeMail),
        icon: const Icon(Icons.edit),
      ),
    );
  }

  Widget getMailFolderBuilder(
      BuildContext context,
      EmailsProvider emailsProvider,
      Widget? child,
      bool isDetailedView,
      Map<int, OtherUserProfile> profileCache) {
    if (emailsProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (emailsProvider.hasError) {
      return Center(child: Text(emailsProvider.errorMessage));
    }
    if (emailsProvider.getFolder(widget.mailbox).isEmpty) {
      return Center(
        child: Text(widget.boxEmptyMessage),
      );
    }

    return ListView.separated(
      itemCount: emailsProvider.getFolder(widget.mailbox).length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final email = emailsProvider.getFolder(widget.mailbox)[index];
        return EmailTile(
          email: email,
          isDetailed: isDetailedView,
          isDisableReadColor: true,
          profileCache: profileCache,
          onTap: () {
            Navigator.pushNamed(
              context,
              MailRoutes.EMAIL_DETAIL.value,
              arguments: {"email": email, "mailbox": widget.mailbox},
            );
          },
          context: context,
          emailsProvider: emailsProvider,
        );
      },
    );
  }
}

class GmailSentScreen extends StatefulWidget {
  const GmailSentScreen({super.key});

  @override
  State<GmailSentScreen> createState() => _GmailSentScreenState();
}

class _GmailSentScreenState extends State<GmailSentScreen> {
  @override
  Widget build(BuildContext context) {
    return MailFolderScreen(
      mailbox: MailBox.SENT.value,
      title: AppLocalizations.of(context)!.sentMail,
      boxEmptyMessage: AppLocalizations.of(context)!.noSentEmails,
    );
  }
}

class GmailStarredScreen extends StatefulWidget {
  const GmailStarredScreen({super.key});

  @override
  State<GmailStarredScreen> createState() => _GmailStarredScreenState();
}

class _GmailStarredScreenState extends State<GmailStarredScreen> {
  @override
  Widget build(BuildContext context) {
    return MailFolderScreen(
      mailbox: MailBox.STARRED.value,
      title: AppLocalizations.of(context)!.starred,
      boxEmptyMessage: AppLocalizations.of(context)!.noTrashedEmails,
    );
  }
}

class GmailTrashScreen extends StatefulWidget {
  const GmailTrashScreen({super.key});

  @override
  State<GmailTrashScreen> createState() => _GmailTrashScreenState();
}

class _GmailTrashScreenState extends State<GmailTrashScreen> {
  @override
  Widget build(BuildContext context) {
    return MailFolderScreen(
      mailbox: MailBox.TRASH.value,
      title: AppLocalizations.of(context)!.trashMail,
      boxEmptyMessage: AppLocalizations.of(context)!.noStarredEmails,
    );
  }
}

class GmailAllScreen extends StatefulWidget {
  const GmailAllScreen({super.key});

  @override
  State<GmailAllScreen> createState() => _GmailAllScreenState();
}

class _GmailAllScreenState extends State<GmailAllScreen> {
  @override
  Widget build(BuildContext context) {
    return MailFolderScreen(
      mailbox: MailBox.ALL.value,
      title: AppLocalizations.of(context)!.allMail,
      boxEmptyMessage: AppLocalizations.of(context)!.noEmails,
    );
  }
}
