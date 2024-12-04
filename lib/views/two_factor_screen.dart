import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'gmail_base_screen.dart';
import '../constants.dart';
import '../utils/api_pipeline.dart';
import '../other_widgets/general.dart';

class Enable2FAScreen extends StatefulWidget {
  const Enable2FAScreen({super.key});

  @override
  State<Enable2FAScreen> createState() => _Enable2FAScreenState();
}

class _Enable2FAScreenState extends State<Enable2FAScreen> {
  bool _isLoading = false;

  Future<void> _enable2FA() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await makeAPIRequest(
        url: Uri.parse(API_Endpoints.ENABLE_2FA.value),
        method: 'POST',
      );

      if (mounted) {
        showSnackBar(context, AppLocalizations.of(context)!.twoFactorEnabled);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, AppLocalizations.of(context)!.errorEnabling2FA);
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GmailBaseScreen(
      title: AppLocalizations.of(context)!.enable2FA,
      addDrawer: false,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(AppLocalizations.of(context)!.enable2FADescription),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _enable2FA,
              child: Text(AppLocalizations.of(context)!.enable2FA),
            ),
            if (_isLoading) ...[
              const SizedBox(height: 16),
              const CircularProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }
}
