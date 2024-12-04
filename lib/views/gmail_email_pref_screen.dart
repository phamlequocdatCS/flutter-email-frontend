import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'gmail_base_screen.dart';
import '../constants.dart';
import '../utils/api_pipeline.dart';
import '../other_widgets/general.dart';

class EmailPrefScreen extends StatefulWidget {
  const EmailPrefScreen({super.key});

  @override
  State<EmailPrefScreen> createState() => _EmailPrefScreenState();
}

class _EmailPrefScreenState extends State<EmailPrefScreen> {
  // Controllers and state variables
  bool _isLoading = true;
  int _fontSize = 14;
  String _fontFamily = 'sans-serif';

  @override
  void initState() {
    super.initState();
    _fetchEmailPrefSettings();
  }

  Future<void> _fetchEmailPrefSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final responseData = await makeAPIRequest(
        url: Uri.parse(API_Endpoints.USER_EMAIL_PREF.value),
        method: 'GET',
      );

      setState(() {
        _fontSize = responseData['font_size'] ?? 14;
        _fontFamily = responseData['font_family'] ?? 'sans-serif';
      });
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

  Future<void> _saveEmailPrefSettings() async {
    // Prepare request body
    final body = {
      'font_size': _fontSize,
      'font_family': _fontFamily,
    };

    try {
      await makeAPIRequest(
        url: Uri.parse(API_Endpoints.USER_EMAIL_PREF.value),
        method: 'PUT',
        body: body,
      );

      if (mounted) {
        showSnackBar(context, AppLocalizations.of(context)!.saveSettingChanges);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, AppLocalizations.of(context)!.errorSavingSettings);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    Map<String, int> fontSizeDisplayMap = {
      AppLocalizations.of(context)!.smallFont: 12,
      AppLocalizations.of(context)!.mediumFont: 14,
      AppLocalizations.of(context)!.largeFont: 16,
    };

    const Map<String, String> fontFamilySelectMap = {
      "Sans-serif": "sans-serif",
      "Serif": "serif",
      "Monospace": "monospace"
    };

    return GmailBaseScreen(
      title: AppLocalizations.of(context)!.emailPrefSetting,
      addDrawer: false,
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Font Size Selection
          Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: const Icon(Icons.format_size, color: Colors.blue),
              title: Text(AppLocalizations.of(context)!.fontSize),
              trailing: DropdownButton<int>(
                value: _fontSize,
                onChanged: (int? newValue) {
                  setState(() {
                    _fontSize = newValue!;
                  });
                },
                items: fontSizeDisplayMap.entries.map<DropdownMenuItem<int>>((entry) {
                  return DropdownMenuItem<int>(
                    value: entry.value,
                    child: Text(entry.key),
                  );
                }).toList(),
              ),
            ),
          ),

          // Font Family Selection
          Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: const Icon(Icons.font_download_outlined, color: Colors.blue),
              title: Text(AppLocalizations.of(context)!.fontFamily),
              trailing: DropdownButton<String>(
                value: _fontFamily,
                onChanged: (String? newValue) {
                  setState(() {
                    _fontFamily = newValue!;
                  });
                },
                items: fontFamilySelectMap.entries.map<DropdownMenuItem<String>>((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.value,
                    child: Text(entry.key),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Save Button
          ElevatedButton(
            onPressed: _saveEmailPrefSettings,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)!.saveSettingChanges),
          ),
        ],
      ),
    );
  }
}
