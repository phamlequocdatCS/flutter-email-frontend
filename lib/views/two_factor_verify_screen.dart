import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state_management/account_provider.dart';

class TwoFactorVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final VoidCallback onSuccess;

  const TwoFactorVerificationScreen({
    super.key, 
    required this.phoneNumber,
    required this.onSuccess,
  });

  @override
  State<TwoFactorVerificationScreen> createState() => _TwoFactorVerificationScreenState();
}

class _TwoFactorVerificationScreenState extends State<TwoFactorVerificationScreen> {
  final TextEditingController _codeController = TextEditingController();
  String? _errorMessage;

  void _verifyCode() async {
    final accountProvider = Provider.of<AccountProvider>(context, listen: false);
    
    try {
      await accountProvider.verify2FA(
        widget.phoneNumber, 
        _codeController.text,
        widget.onSuccess,
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Invalid verification code. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Two-Factor Authentication')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter the 6-digit verification code sent to your email',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: 'Verification Code',
                errorText: _errorMessage,
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _verifyCode,
              child: const Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }
}