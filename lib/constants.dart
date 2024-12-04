// ignore_for_file: camel_case_types

import 'package:flutter/foundation.dart';

const Route404 = "404";
const placeholderImage = "assets/placeholder.jpg";
const appName = "GotMail";

enum SettingsRoutes {
  ROOT("settings/"),
  USER("settings/userSettings"),
  AUTOREP("settings/autoReply"),
  LABELS("settings/labels"),
  EDITPROFILE("settings/editProfile"),
  COMPOSEPREF("settings/composePrefs"),
  VERIFYPHONE("settings/verifyPhone"),
  ENABLE_2FA("settings/2fa"),
  PASSWORD_RESET("settings/passReset"),
  ;

  const SettingsRoutes(this.value);
  final String value;
}

enum AuthRoutes {
  ROOT("/"),
  LOGIN("/"),
  AUTHROOT("auth/"),
  REGISTER("auth/register");

  const AuthRoutes(this.value);
  final String value;
}

enum MailRoutes {
  INBOX("/inbox"),
  EMAIL_DETAIL("/emailDetail"),
  COMPOSE("/compose"),
  NOTIF("/notif"),
  DRAFT("/draft"),
  ;

  const MailRoutes(this.value);
  final String value;
}

enum MailSubroutes {
  ROOT("mails/"),
  DRAFT("mails/drafts"),
  SENT("mails/sent"),
  TRASH("mails/trash"),
  STARRED("mails/starred"),
  SPAM("mails/spam"),
  ALL("mails/allMail");

  const MailSubroutes(this.value);
  final String value;
}

const String ROOT = kIsWeb
    // ? "127.0.0.1:8000" // Web
    ? "simulated-email-backend.onrender.com" // Web
    : "10.0.2.2:8000"; // Android

const String API_ROOT = kIsWeb
    ? "http://$ROOT" // Web
    : "http://$ROOT"; // Android

const String mediaServer = kIsWeb
    ? "http://$ROOT" // Web
    : "http://$ROOT"; // Android

enum API_Endpoints {
  AUTH_REGISTER("$API_ROOT/auth/register/"),
  AUTH_LOGIN("$API_ROOT/auth/login/"),
  AUTH_LOGOUT("$API_ROOT/auth/logout/"),
  AUTH_VALIDATE_TOKEN("$API_ROOT/auth/validate_token/"),
  USER_PROFILE("$API_ROOT/user/profile/"),
  GET_IMAGE(mediaServer),
  GET_ATTACHMENT(mediaServer),
  USER_AUTO_REPLY("$API_ROOT/user/auto_rep/"),
  USER_DARKMODE("$API_ROOT/user/darkmode/"),
  USER_EMAIL_PREF("$API_ROOT/user/email_pref/"),
  EMAIL_SEND("$API_ROOT/email/send/"),
  EMAIL_LIST("$API_ROOT/email_list"),
  EMAIL_SYNC("$API_ROOT/email_sync"),
  EMAIL_ACTION("$API_ROOT/email/action/"),
  USER_LABEL("$API_ROOT/user/labels/"),
  EMAIL_LABEL("$API_ROOT/user/email_labels/"),
  OTHER_USER_PROFILE("$API_ROOT/other/profile/"),
  NOTIFICATIONS("$API_ROOT/user/notifications/"),
  REQUEST_VERIFICATION("$API_ROOT/auth/verify/start/"),
  VERIFY_CODE("$API_ROOT/auth/verify/code/"),
  PASSWORD_RESET("$API_ROOT/auth/reset_password/"),
  PASSWORD_RESET_CONFIRM("$API_ROOT/auth/reset_password_confirm/"),
  FORGET_PASSWORD("$API_ROOT/auth/forget_password/"),
  ENABLE_2FA("$API_ROOT/auth/2fa/"),
  AUTH_VERIFY_2FA("$API_ROOT/auth/2fa_verify/"),
  ;

  const API_Endpoints(this.value);
  final String value;
}

String getUserProfileImageURL(String url) {
  return "${API_Endpoints.GET_IMAGE.value}$url";
}

String getAttachmentURL(String url) {
  return url;
}

enum MailBox {
  INBOX("inbox"),
  SENT("sent"),
  TRASH("trash"),
  DRAFT("draft"),
  SPAM("spam"),
  STARRED("starred"),
  ALL("all");

  const MailBox(this.value);
  final String value;
}

const List<String> fontSizes = ["Small", "Medium", "Large"];
const List<String> fontFamilies = ["Sans-serif", "Serif", "Monospace"];

const Map<String, String> fontFamilySelectMap = {
  "Sans-serif": "sans-serif",
  "Serif": "serif",
  "Monospace": "monospace"
};

var fontFamilyValueMap = fontFamilySelectMap.map((k, v) => MapEntry(v, k));
