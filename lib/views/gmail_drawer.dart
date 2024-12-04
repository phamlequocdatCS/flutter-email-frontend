import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../constants.dart';
import '../data_classes.dart';
import '../other_widgets/drawer.dart';
import '../other_widgets/general.dart';
import '../other_widgets/notification.dart';
import '../state_management/account_provider.dart';
import '../state_management/notification_provider.dart';

class GmailDrawer extends StatelessWidget {
  const GmailDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final accountProvider = Provider.of<AccountProvider>(context);
    final currentAccount = accountProvider.currentAccount!;
    final notificationProvider = Provider.of<UserNotificationProvider>(context);

    Color textColor = Theme.of(context).colorScheme.onSecondary;
    Color iconColor = Theme.of(context).iconTheme.color!;
    Color drawerHeaderColor = Theme.of(context).colorScheme.secondary;
    Color dividerColor = Theme.of(context).dividerColor;
    Color drawerTextColor = Theme.of(context).colorScheme.onSurface;

    ListTile drawerItem(
      Object? arguments, {
      required IconData icon,
      required String titleKey,
      required String route,
      bool isReplacement = false,
    }) {
      return buildDrawerItem(
        icon,
        titleKey,
        route,
        context,
        drawerTextColor,
        iconColor,
        arguments,
        isReplacement: isReplacement,
      );
    }

    Map<String, Map<String, dynamic>> drawerGroup_1 = {
      // "drafts": {
      //   "icon": Icons.drafts,
      //   "titleKey": AppLocalizations.of(context)!.drafts,
      //   "route": MailSubroutes.DRAFT.value
      // },
      "sent": {
        "icon": Icons.send,
        "titleKey": AppLocalizations.of(context)!.sent,
        "route": MailSubroutes.SENT.value
      },
      "trash": {
        "icon": Icons.recycling,
        "titleKey": AppLocalizations.of(context)!.trash,
        "route": MailSubroutes.TRASH.value
      },
    };

    Map<String, Map<String, dynamic>> drawerGroup_2 = {
      "starred": {
        "icon": Icons.star,
        "titleKey": AppLocalizations.of(context)!.starred,
        "route": MailSubroutes.STARRED.value
      },
      "spam": {
        "icon": Icons.delete,
        "titleKey": AppLocalizations.of(context)!.spam,
        "route": MailSubroutes.SPAM.value
      },
      "draft": {
        "icon": Icons.drafts,
        "titleKey": AppLocalizations.of(context)!.drafts,
        "route": MailRoutes.DRAFT.value
      },
      "allMail": {
        "icon": Icons.all_inbox,
        "titleKey": AppLocalizations.of(context)!.allMail,
        "route": MailSubroutes.ALL.value
      },
    };

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          getDrawerHeader(
            drawerHeaderColor,
            textColor,
            context,
            currentAccount,
          ),
          drawerItem(
            currentAccount,
            icon: Icons.inbox,
            titleKey: AppLocalizations.of(context)!.inbox,
            route: MailRoutes.INBOX.value,
            isReplacement: true,
          ),
          Stack(
            children: [
              drawerItem(
                null,
                icon: Icons.notifications,
                titleKey: AppLocalizations.of(context)!.notifications,
                route: MailRoutes.NOTIF.value,
              ),
              if (notificationProvider.unreadNotificationsCount > 0)
                getUnreadNotifBubble(notificationProvider),
            ],
          ),
          ...drawerGroup_1.values.map((value) {
            return drawerItem(
              null,
              icon: value["icon"],
              titleKey: value["titleKey"],
              route: value["route"],
            );
          }),
          Divider(
            color: dividerColor,
          ),
          ...drawerGroup_2.values.map((value) {
            return drawerItem(
              null,
              icon: value["icon"],
              titleKey: value["titleKey"],
              route: value["route"],
            );
          }),
          Divider(color: dividerColor),
          drawerItem(
            currentAccount,
            icon: Icons.settings,
            titleKey: AppLocalizations.of(context)!.settings,
            route: SettingsRoutes.USER.value,
          ),
        ],
      ),
    );
  }
}

UserAccountsDrawerHeader getDrawerHeader(
  Color drawerHeaderColor,
  Color textColor,
  BuildContext context,
  Account currentAccount,
) {
  return UserAccountsDrawerHeader(
    decoration: BoxDecoration(
      color: drawerHeaderColor,
    ),
    accountName: Text(
      "${currentAccount.first_name} ${currentAccount.last_name}",
      style: TextStyle(color: textColor),
    ),
    accountEmail: Text(
      currentAccount.email,
      style: TextStyle(color: textColor.withOpacity(0.7)),
    ),
    currentAccountPicture: CircleAvatar(
      backgroundImage: getImageFromAccount(currentAccount),
    ),
    otherAccountsPictures: [
      IconButton(
        icon: Icon(Icons.edit, color: textColor),
        onPressed: () {
          Navigator.pushNamed(
            context,
            SettingsRoutes.EDITPROFILE.value,
          );
        },
      ),
    ],
  );
}
