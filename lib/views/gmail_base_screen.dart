import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../other_widgets/notification.dart';
import '../state_management/notification_provider.dart';
import 'gmail_drawer.dart';
import '../other_widgets/locale_switcher.dart';
import '../state_management/locale_provider.dart';
import '../state_management/account_provider.dart';

class GmailBaseScreen extends StatefulWidget {
  final String title;
  final Widget body;
  final Widget? appBarWidget;
  final FloatingActionButton? floatingActionButton;
  final bool addDrawer;

  const GmailBaseScreen({
    super.key,
    required this.title,
    required this.body,
    this.appBarWidget,
    this.floatingActionButton,
    this.addDrawer = true,
  });

  @override
  State<GmailBaseScreen> createState() => _GmailBaseScreenState();
}

class _GmailBaseScreenState extends State<GmailBaseScreen> {
  final FocusNode _focusNode = FocusNode();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Fetch notifications when the widget is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notificationProvider =
          Provider.of<UserNotificationProvider>(context, listen: false);
      notificationProvider.fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the current locale from LocaleProvider
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale ??
        Localizations.localeOf(
          context,
        );

    final accountProvider = Provider.of<AccountProvider>(context);
    final notificationProvider = Provider.of<UserNotificationProvider>(context);

    final drawer = widget.addDrawer && accountProvider.currentAccount != null
        ? const GmailDrawer()
        : null;
    final drawerIcon =
        drawer != null ? getDrawerIcon(notificationProvider) : null;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: widget.appBarWidget ?? Text(widget.title),
        actions: getLanguageChangeDropdown(
          currentLocale,
          context,
          localeProvider,
          _focusNode,
        ),
        leading: drawerIcon,
      ),
      drawer: drawer,
      body: GestureDetector(
        onTap: () {
          // Unfocus the dropdown when the body is tapped
          _focusNode.unfocus();
        },
        child: widget.body,
      ),
      floatingActionButton: widget.floatingActionButton,
    );
  }

  Stack getDrawerIcon(UserNotificationProvider notificationProvider) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        if (notificationProvider.unreadNotificationsCount > 0)
          getUnreadNotifBubble(notificationProvider),
      ],
    );
  }

  @override
  void dispose() {
    // Dispose the FocusNode when the widget is disposed
    _focusNode.dispose();
    super.dispose();
  }
}
