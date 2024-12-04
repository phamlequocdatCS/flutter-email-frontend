import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../constants.dart';
import '../other_widgets/general.dart';
import '../utils/api_pipeline.dart';
import '../state_management/account_provider.dart';

class VerifyPhoneScreen extends StatefulWidget {
  const VerifyPhoneScreen({super.key});

  @override
  State<VerifyPhoneScreen> createState() => _VerifyPhoneScreenState();
}

class _VerifyPhoneScreenState extends State<VerifyPhoneScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  bool _isLoading = false;
  bool _isCodeSent = false;

  @override
  void initState() {
    super.initState();
    final accountProvider =
        Provider.of<AccountProvider>(context, listen: false);
    _phoneController.text = accountProvider.currentAccount!.phone_number;
  }

  Future<void> _requestVerificationCode() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final body = {
        'phone_number': _phoneController.text,
      };

      await makeAPIRequest(
        url: Uri.parse(API_Endpoints.REQUEST_VERIFICATION.value),
        method: 'POST',
        body: body,
      );

      setState(() {
        _isCodeSent = true;
      });

      if (mounted) {
        showSnackBar(context, AppLocalizations.of(context)!.codeSent);
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, AppLocalizations.of(context)!.errorSendingCode);
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyCode() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final body = {
        'phone_number': _phoneController.text,
        'code': _codeController.text,
      };

      await makeAPIRequest(
        url: Uri.parse(API_Endpoints.VERIFY_CODE.value),
        method: 'POST',
        body: body,
      );

      if (mounted) {
        showSnackBar(context, AppLocalizations.of(context)!.phoneVerified);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(
            context, AppLocalizations.of(context)!.invalidVerificationCode);
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.verifyPhoneNumber),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                enabled: false,
                readOnly: true,
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.phoneNumber,
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.enterPhoneNumber;
                  }
                  return null;
                },
              ),
              if (_isCodeSent) ...[
                TextFormField(
                  controller: _codeController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.verificationCode,
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!
                          .enterVerificationCode;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _verifyCode,
                  child: Text(AppLocalizations.of(context)!.verify),
                ),
              ] else ...[
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _requestVerificationCode,
                  child: Text(AppLocalizations.of(context)!.requestCode),
                ),
              ],
              if (_isLoading) ...[
                const SizedBox(height: 16),
                const CircularProgressIndicator(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
