import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'manager.dart';
import 'constants.dart';
import 'state_management/draft_provider.dart';
import 'state_management/email_provider.dart';
import 'state_management/label_provider.dart';
import 'state_management/theme_provider.dart';
import 'state_management/locale_provider.dart';
import 'state_management/account_provider.dart';
import 'state_management/notification_provider.dart';
import 'state_management/email_compose_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeProvider = ThemeProvider();
  await themeProvider.fetchDarkModeSetting();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LocaleProvider()),
        ChangeNotifierProvider(create: (context) => EmailsProvider()),
        ChangeNotifierProvider(create: (context) => AccountProvider()),
        ChangeNotifierProvider(create: (context) => themeProvider),
        ChangeNotifierProvider(create: (context) => EmailComposeProvider()),
        ChangeNotifierProvider(create: (context) => LabelProvider()),
        ChangeNotifierProvider(create: (context) => UserNotificationProvider()),
        ChangeNotifierProvider(create: (context) => DraftsProvider()),
        // Add other providers here in the future
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: appName,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: localeProvider.locale,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.purple,
        brightness: Brightness.dark,
      ),
      themeMode: themeProvider.themeMode,
      initialRoute: AuthRoutes.LOGIN.value,
      onGenerateRoute: (settings) => getRouterManager(settings, context),
    );
  }
}
