import 'package:flutter/material.dart';

import 'constants.dart';
import 'auth/login.dart';
import 'auth/register.dart';
import 'views/draft_screen.dart';
import 'views/mail_folder_screen.dart';
import 'views/gmail_inbox_screen.dart';
import 'views/edit_profile_screen.dart';
import 'views/notifications_screen.dart';
import 'views/two_factor_screen.dart';
import 'views/user_settings_screen.dart';
import 'views/label_settings_screen.dart';
import 'views/gmail_email_pref_screen.dart';
import 'views/gmail_email_detail_screen.dart';
import 'views/gmail_compose_email_screen.dart';
import 'views/auto_reply_settings_screen.dart';
import 'views/verify_phone_screen.dart';

PageRouteBuilder getRouterManager(
  RouteSettings settings,
  BuildContext context,
) {
  print(settings.name);
  if (settings.name != null) {
    if (settings.name!.startsWith(AuthRoutes.ROOT.value)) {
      return MainManager.redirector(
        context,
        settings.name!,
        arguments: settings.arguments,
      );
    } else if (settings.name!.startsWith(SettingsRoutes.ROOT.value)) {
      return SettingManager.redirector(context, settings.name!);
    } else if (settings.name!.startsWith(AuthRoutes.AUTHROOT.value)) {
      return LoginManager.redirector(context, settings.name!);
    } else if (settings.name!.startsWith(MailSubroutes.ROOT.value)) {
      return SubManager.redirector(context, settings.name!);
    }
  }
  return MainManager.redirector(context, Route404);
}

class Screen404 extends StatelessWidget {
  const Screen404({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
      ),
      body: const Center(child: Text('Page not found')),
    );
  }
}

abstract class RouterManager {}

class MainManager extends RouterManager {
  static PageRouteBuilder redirector(
    BuildContext context,
    String path, {
    Object? arguments,
  }) {
    final Map<String, WidgetBuilder> routeMap = {
      AuthRoutes.LOGIN.value: (context) => const GmailLoginScreen(),
      MailRoutes.INBOX.value: (context) => const GmailInboxScreen(),
      MailRoutes.EMAIL_DETAIL.value: (context) => GmailEmailDetailScreen(
            email: (arguments as Map)["email"],
            mailbox: arguments["mailbox"],
          ),
      MailRoutes.NOTIF.value: (context) => const EmailNotifications(),
      MailRoutes.COMPOSE.value: (context) => const EmailComposeScreen(),
      MailRoutes.DRAFT.value: (context) => const DraftsScreen(),
    };

    WidgetBuilder builder = routeMap[path] ?? (context) => const Screen404();
    return tweenRoute(builder);
  }
}

class SubManager extends RouterManager {
  static PageRouteBuilder redirector(
    BuildContext context,
    String path, {
    Object? arguments,
  }) {
    final Map<String, WidgetBuilder> routeMap = {
      MailSubroutes.SENT.value: (context) => const GmailSentScreen(),
      MailSubroutes.STARRED.value: (context) => const GmailStarredScreen(),
      MailSubroutes.TRASH.value: (context) => const GmailTrashScreen(),
      MailSubroutes.ALL.value: (context) => const GmailAllScreen(),
    };

    WidgetBuilder builder = routeMap[path] ?? (context) => const Screen404();
    return tweenRoute(builder);
  }
}

class SettingManager extends RouterManager {
  static const root = "settings/";

  static PageRouteBuilder redirector(
    BuildContext context,
    String path, {
    Object? arguments,
  }) {
    final Map<String, WidgetBuilder> routeMap = {
      SettingsRoutes.USER.value: (context) => const UserSettingsScreen(),
      SettingsRoutes.AUTOREP.value: (context) =>
          const AutoReplySettingsScreen(),
      SettingsRoutes.EDITPROFILE.value: (context) => const EditProfileScreen(),
      SettingsRoutes.COMPOSEPREF.value: (context) => const EmailPrefScreen(),
      SettingsRoutes.LABELS.value: (context) => const LabelManagementScreen(),
      SettingsRoutes.VERIFYPHONE.value: (context) => const VerifyPhoneScreen(),
      SettingsRoutes.ENABLE_2FA.value: (context) => const Enable2FAScreen(),
      // SettingsRoutes.PASSWORD_RESET.value: (context) =>
      //     const PasswordResetScreen(),
    };

    WidgetBuilder builder = routeMap[path] ?? (context) => const Screen404();
    return tweenRoute(builder);
  }
}

class LoginManager extends RouterManager {
  static PageRouteBuilder redirector(
    BuildContext context,
    String path, {
    Object? arguments,
  }) {
    final Map<String, WidgetBuilder> routeMap = {
      AuthRoutes.REGISTER.value: (context) => const GmailRegisterScreen(),
    };

    WidgetBuilder builder =
        routeMap[path] ?? (context) => const GmailLoginScreen();
    return tweenRoute(builder);
  }
}

PageRouteBuilder<dynamic> tweenRoute(WidgetBuilder builder) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var slideTween = Tween(begin: begin, end: end).chain(
        CurveTween(
          curve: curve,
        ),
      );
      var slideAnimation = animation.drive(slideTween);

      var fadeTween = Tween(begin: 0.0, end: 1.0).chain(
        CurveTween(
          curve: curve,
        ),
      );
      var fadeAnimation = animation.drive(fadeTween);

      return FadeTransition(
        opacity: fadeAnimation,
        child: SlideTransition(
          position: slideAnimation,
          child: child,
        ),
      );
    },
  );
}
