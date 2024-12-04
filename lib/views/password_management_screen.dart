import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../constants.dart';
import '../other_widgets/general.dart';
import '../other_widgets/password_management.dart';
import '../utils/api_pipeline.dart';
import 'forget_reset_password_screen.dart';
import 'gmail_base_screen.dart';

enum PasswordScreenType { forgetPassword, resetPassword }

class PasswordScreen extends StatefulWidget {
  final PasswordScreenType screenType;

  const PasswordScreen({super.key, required this.screenType});

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleSubmit() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final body = {
        'email': _emailController.text,
        if (widget.screenType == PasswordScreenType.forgetPassword)
          'phone_number': _phoneController.text,
      };

      final url = widget.screenType == PasswordScreenType.forgetPassword
          ? API_Endpoints.FORGET_PASSWORD.value
          : API_Endpoints.PASSWORD_RESET.value;

      await makeAPIRequest(
        url: Uri.parse(url),
        method: 'POST',
        body: body,
        requiresAuth: widget.screenType == PasswordScreenType.resetPassword
      );

      if (mounted) {
        final successMessage =
            widget.screenType == PasswordScreenType.forgetPassword
                ? AppLocalizations.of(context)!.passwordResetEmailSent
                : AppLocalizations.of(context)!.passwordResetEmailSent;

        showSnackBar(context, successMessage);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordScreen(
              email: _emailController.text,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(
          context,
          AppLocalizations.of(context)!.errorSendingPasswordResetEmail,
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
    final isForgetPassword =
        widget.screenType == PasswordScreenType.forgetPassword;

    return GmailBaseScreen(
      title: isForgetPassword
          ? AppLocalizations.of(context)!.forgetPassword
          : AppLocalizations.of(context)!.passwordReset,
      addDrawer: false,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isForgetPassword
            ? getForgetPasswordRequestForm(
                context,
                _handleSubmit,
                _formKey,
                _isLoading,
                _emailController,
                _phoneController,
              )
            : getChangePasswordRequestForm(
                context,
                _handleSubmit,
                _formKey,
                _isLoading,
                _emailController,
              ),
      ),
    );
  }
}
