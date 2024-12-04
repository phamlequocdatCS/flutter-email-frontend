import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

TextFormField getInputField(
  BuildContext context,
  TextEditingController controller,
  String labelText,
  String errorText, {
  TextInputType keyboardType = TextInputType.text,
}) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: labelText,
    ),
    keyboardType: keyboardType,
    validator: (value) {
      if (value == null || value.isEmpty) {
        return errorText;
      }
      return null;
    },
  );
}

TextFormField getCodeField(
  BuildContext context,
  TextEditingController codeController,
) {
  return getInputField(
    context,
    codeController,
    AppLocalizations.of(context)!.verificationCode,
    AppLocalizations.of(context)!.enterVerificationCode,
  );
}

TextFormField getNewPasswordField(
  BuildContext context,
  TextEditingController newPasswordController,
) {
  return getInputField(
    context,
    newPasswordController,
    AppLocalizations.of(context)!.newPassword,
    AppLocalizations.of(context)!.pleaseEnterNewPassword,
  );
}

TextFormField getEmailField(
  BuildContext context,
  TextEditingController emailController,
) {
  return getInputField(context, emailController, "Email",
      AppLocalizations.of(context)!.pleaseEnterEmail,
      keyboardType: TextInputType.emailAddress);
}

TextFormField getPhoneField(
  BuildContext context,
  TextEditingController phoneController,
) {
  return getInputField(
      context,
      phoneController,
      AppLocalizations.of(context)!.phoneNumber,
      AppLocalizations.of(context)!.enterPhoneNumber,
      keyboardType: TextInputType.phone);
}

Form getResetPasswordConfirmForm(
  BuildContext context,
  VoidCallback onConfirm,
  GlobalKey<FormState> formKey,
  bool isLoading,
  TextEditingController codeController,
  TextEditingController newPasswordController,
) {
  return Form(
    key: formKey,
    child: Column(
      children: [
        getCodeField(context, codeController),
        const SizedBox(height: 16),
        getNewPasswordField(context, newPasswordController),
        const SizedBox(height: 16),
        getConfirmResetButton(isLoading, onConfirm, context),
        if (isLoading) ...[
          const SizedBox(height: 16),
          const CircularProgressIndicator(),
        ],
      ],
    ),
  );
}

Form getForgetPasswordRequestForm(
  BuildContext context,
  VoidCallback onConfirm,
  GlobalKey<FormState> formKey,
  bool isLoading,
  TextEditingController emailController,
  TextEditingController phoneController,
) {
  return Form(
    key: formKey,
    child: Column(
      children: [
        getEmailField(context, emailController),
        const SizedBox(height: 16),
        getPhoneField(context, phoneController),
        const SizedBox(height: 16),
        getConfirmResetButton(isLoading, onConfirm, context),
        if (isLoading) ...[
          const SizedBox(height: 16),
          const CircularProgressIndicator(),
        ],
      ],
    ),
  );
}

ElevatedButton getConfirmResetButton(
  bool isLoading,
  VoidCallback onConfirm,
  BuildContext context,
) {
  return ElevatedButton(
    onPressed: isLoading ? null : onConfirm,
    child: Text(AppLocalizations.of(context)!.confirmPasswordReset),
  );
}

Form getChangePasswordRequestForm(
  BuildContext context,
  VoidCallback onConfirm,
  GlobalKey<FormState> formKey,
  bool isLoading,
  TextEditingController emailController,
) {
  return Form(
    key: formKey,
    child: Column(
      children: [
        getEmailField(context, emailController),
        const SizedBox(height: 16),
        getConfirmResetButton(isLoading, onConfirm, context),
        if (isLoading) ...[
          const SizedBox(height: 16),
          const CircularProgressIndicator(),
        ],
      ],
    ),
  );
}
