import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'gmail_base_screen.dart';
import '../constants.dart';
import '../utils/api_pipeline.dart';
import '../other_widgets/general.dart';
import '../state_management/theme_provider.dart';
import '../state_management/account_provider.dart';

class UserSettingsScreen extends StatefulWidget {
  const UserSettingsScreen({super.key});

  @override
  State<UserSettingsScreen> createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDarkModeSetting();
  }

  Future<void> _fetchDarkModeSetting() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      await themeProvider.fetchDarkModeSetting();
    } catch (e) {
      if (mounted) {
        showSnackBar(context, AppLocalizations.of(context)!.errorFetchSettings);
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleDarkMode(bool value) async {
    try {
      final body = {
        'dark_mode': value,
      };

      await makeAPIRequest(
        url: Uri.parse(API_Endpoints.USER_DARKMODE.value),
        method: 'PATCH',
        body: body,
      );

      if (mounted) {
        final themeProvider = Provider.of<ThemeProvider>(
          context,
          listen: false,
        );
        themeProvider.setThemeMode(value);
        showSnackBar(context, AppLocalizations.of(context)!.saveSettingChanges);
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(
          context,
          AppLocalizations.of(context)!.errorSavingSettings,
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final themeProvider = Provider.of<ThemeProvider>(context);

    return GmailBaseScreen(
      title: AppLocalizations.of(context)!.userSettings,
      body: ListView(
        children: [
          Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: const Icon(Icons.account_circle, color: Colors.blue),
              title: Text(AppLocalizations.of(context)!.changeProfile),
              subtitle: Text(AppLocalizations.of(context)!.updateNamePic),
              trailing: const Icon(Icons.edit),
              onTap: () {
                Navigator.pushNamed(context, SettingsRoutes.EDITPROFILE.value);
              },
            ),
          ),
          Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: const Icon(Icons.lock, color: Colors.blue),
              title: Text(AppLocalizations.of(context)!.changePassword),
              trailing: const Icon(Icons.lock_open),
              onTap: () {
                Navigator.pushNamed(context, SettingsRoutes.PASSWORD_RESET.value);
              },
            ),
          ),
          Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: const Icon(Icons.auto_awesome, color: Colors.blue),
              title: Text(AppLocalizations.of(context)!.autoRepSetting),
              subtitle: Text(AppLocalizations.of(context)!.autoRepDesc),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.pushNamed(context, SettingsRoutes.AUTOREP.value);
              },
            ),
          ),
          Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: const Icon(Icons.label_important_outlined, color: Colors.blue),
              title: Text(AppLocalizations.of(context)!.labelManagement),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.pushNamed(context, SettingsRoutes.LABELS.value);
              },
            ),
          ),
          Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: const Icon(Icons.reply, color: Colors.blue),
              title: Text(AppLocalizations.of(context)!.emailPrefSetting),
              subtitle: Text(AppLocalizations.of(context)!.emailPrefDesc),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.pushNamed(context, SettingsRoutes.COMPOSEPREF.value);
              },
            ),
          ),
          Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: const Icon(Icons.phone, color: Colors.blue),
              title: Text(AppLocalizations.of(context)!.verifyPhoneNumber),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.pushNamed(context, SettingsRoutes.VERIFYPHONE.value);
              },
            ),
          ),
          Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: const Icon(Icons.security, color: Colors.blue),
              title: Text(AppLocalizations.of(context)!.enable2FA),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.pushNamed(context, SettingsRoutes.ENABLE_2FA.value);
              },
            ),
          ),
          Card(
            margin: const EdgeInsets.all(8),
            child: SwitchListTile(
              title: Text(AppLocalizations.of(context)!.darkModeToggle),
              secondary: const Icon(Icons.brightness_6, color: Colors.blue),
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                print(value);
                _toggleDarkMode(value);
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(AppLocalizations.of(context)!.logout),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  void _logout() async {
    await Provider.of<AccountProvider>(context, listen: false).logout();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(AuthRoutes.LOGIN.value);
    }
  }
}
