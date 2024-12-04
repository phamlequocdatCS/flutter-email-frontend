import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../constants.dart';
import '../other_widgets/general.dart';
import '../other_widgets/password_management.dart';
import '../utils/api_pipeline.dart';
import 'gmail_base_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _confirmPasswordReset() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final body = {
        'email': widget.email,
        'code': _codeController.text,
        'new_password': _newPasswordController.text,
      };

      await makeAPIRequest(
        url: Uri.parse(API_Endpoints.PASSWORD_RESET_CONFIRM.value),
        method: 'POST',
        body: body,
        requiresAuth: false
      );

      if (mounted) {
        showSnackBar(
          context,
          AppLocalizations.of(context)!.passwordResetSuccess,
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(
          context,
          AppLocalizations.of(context)!.errorResettingPassword,
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
    return GmailBaseScreen(
      title: AppLocalizations.of(context)!.passwordReset,
      addDrawer: false,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: getResetPasswordConfirmForm(
          context,
          _confirmPasswordReset,
          _formKey,
          _isLoading,
          _codeController,
          _newPasswordController,
        ),
      ),
    );
  }
}
