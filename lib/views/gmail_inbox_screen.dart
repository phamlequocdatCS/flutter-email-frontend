import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../state_management/notification_provider.dart';
import 'gmail_base_screen.dart';
import '../constants.dart';
import '../data_classes.dart';
import '../other_widgets/email.dart';
import '../other_widgets/general.dart';
import '../other_widgets/searcher.dart';
import '../state_management/label_provider.dart';
import '../state_management/email_provider.dart';

class GmailInboxScreen extends StatefulWidget {
  const GmailInboxScreen({super.key});

  @override
  State<GmailInboxScreen> createState() => _GmailInboxScreenState();
}

class _GmailInboxScreenState extends State<GmailInboxScreen> {
  bool _isDetailedView = false;
  final Map<int, OtherUserProfile> profileCache = {};
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeScreen();
    });
  }

  void _initializeScreen() {
    final emailsProvider = Provider.of<EmailsProvider>(context, listen: false);
    final notificationProvider =
        Provider.of<UserNotificationProvider>(context, listen: false);

    // Only refresh if not already initialized or cache is stale
    if (!_isInitialized || emailsProvider.isCacheStale('inbox')) {
      emailsProvider.fetchEmails(); // This will use cached data if still fresh
      Provider.of<LabelProvider>(context, listen: false).fetchLabels();

      // Initialize WebSocket only if not already connected
      if (emailsProvider.webSocketService == null) {
        emailsProvider.initializeWebSocket(notificationProvider);
      }

      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 700;
    Widget viewToggleWidget = ElevatedButton.icon(
      onPressed: () {
        setState(() {
          _isDetailedView = !_isDetailedView;
        });
      },
      icon: Icon(
        _isDetailedView ? Icons.view_compact : Icons.view_agenda,
      ),
      label: Visibility(
        visible: !isCompact,
        replacement: const SizedBox.shrink(),
        child: Text(
          _isDetailedView
              ? AppLocalizations.of(context)!.compactView
              : AppLocalizations.of(context)!.detailedView,
        ),
      ),
    );
    return GmailBaseScreen(
      title: AppLocalizations.of(context)!.inbox,
      appBarWidget: getUltimateEmailBar(viewToggleWidget, MailBox.INBOX.value),
      body: Column(
        children: [
          Expanded(
            child: Consumer<EmailsProvider>(
              builder: (context, emailsProvider, child) => getInboxBuilder(
                context,
                emailsProvider,
                child,
                _isDetailedView,
                profileCache,
              ),
            ),
          ),
        ],
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

  Widget getInboxBuilder(
    BuildContext context,
    EmailsProvider emailsProvider,
    Widget? child,
    bool isDetailedView,
    Map<int, OtherUserProfile> profileCache,
  ) {
    if (emailsProvider.isLoading) {
      return centerCircleProgress;
    }

    if (emailsProvider.hasError) {
      return Center(child: Text(emailsProvider.errorMessage));
    }

    if (emailsProvider.emails.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.noEmails));
    }

    return ListView.builder(
      itemCount: emailsProvider.emails.length * 2 - 1, // Account for dividers
      itemBuilder: (context, index) {
        if (index.isOdd) {
          return const Divider(height: 1);
        }

        final emailIndex = index ~/ 2;
        final email = emailsProvider.emails[emailIndex];
        return EmailTile(
          email: email,
          isDetailed: isDetailedView,
          profileCache: profileCache,
          onTap: () {
            Navigator.pushNamed(
              context,
              MailRoutes.EMAIL_DETAIL.value,
              arguments: {"email": email, "mailbox": MailBox.INBOX.value},
            );
          },
          context: context,
          emailsProvider: emailsProvider,
        );
      },
    );
  }
}
