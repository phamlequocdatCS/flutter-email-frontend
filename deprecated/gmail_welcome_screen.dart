import 'package:flutter/material.dart';

class GmailWelcomeScreen extends StatelessWidget {
  final String email;

  GmailWelcomeScreen({required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Google',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chào mừng',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(email, style: TextStyle(fontSize: 18, color: Colors.grey)),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/inbox');
              },
              child: Text('Vào hộp thư'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
