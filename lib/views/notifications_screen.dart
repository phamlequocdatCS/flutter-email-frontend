import 'package:flutter/material.dart';
import 'package:flutter_email/data_classes.dart';
import 'package:provider/provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../other_widgets/general.dart';
import 'gmail_base_screen.dart';
import '../constants.dart';
import '../state_management/email_provider.dart';
import '../state_management/notification_provider.dart';

class EmailNotifications extends StatefulWidget {
  const EmailNotifications({super.key});

  @override
  State<EmailNotifications> createState() => _EmailNotificationsState();
}

class _EmailNotificationsState extends State<EmailNotifications> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserNotificationProvider>(context, listen: false)
          .fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GmailBaseScreen(
      title: AppLocalizations.of(context)!.notifications,
      addDrawer: false,
      body: Column(
        children: [
          Expanded(
            child: Consumer<UserNotificationProvider>(
              builder: (context, notificationProvider, child) =>
                  getNotifBuilder(context, notificationProvider, child),
            ),
          ),
        ],
      ),
    );
  }

  getNotifBuilder(
    BuildContext context,
    UserNotificationProvider notificationProvider,
    Widget? child,
  ) {
    return ListView.separated(
      itemCount: notificationProvider.notifications.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final notification = notificationProvider.notifications[index];
        return getNotificationTile(notification, notificationProvider, context);
      },
    );
  }

  ListTile getNotificationTile(
    UserNotification notification,
    UserNotificationProvider notificationProvider,
    BuildContext context,
  ) {
    return ListTile(
      leading: Icon(
        notification.isRead ? Icons.mark_email_read : Icons.mark_email_unread,
        color: notification.isRead ? Colors.grey : Colors.blue,
      ),
      title: Text(notification.message),
      subtitle: Text(notification.createdAt.toString()),
      onTap: () {
        notificationProvider.updateNotificationReadStatus(
          notification.id,
          !notification.isRead,
        );
        if (!notification.isRead) {
          final emailsProvider =
              Provider.of<EmailsProvider>(context, listen: false);
          try {
            final email = emailsProvider.emails.firstWhere(
              (email) => email.message_id == notification.emailID,
            );
            Navigator.pushNamed(
              context,
              MailRoutes.EMAIL_DETAIL.value,
              arguments: {"email": email, "mailbox": MailBox.INBOX.value},
            );
          } catch (e) {
            showSnackBar(
              context,
              AppLocalizations.of(context)!.emailNotFound,
            );
          }
        }
      },
    );
  }
}
