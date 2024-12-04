import 'package:flutter/material.dart';
import 'gmail_base_screen.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;

  PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return GmailBaseScreen(
      title: title,
      body: Center(
        child:
            Text('This is the $title screen.', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
