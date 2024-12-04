import 'package:flutter/material.dart';

class GmailPasswordScreen extends StatefulWidget {
  final String email;

  const GmailPasswordScreen({super.key, required this.email});

  @override
  State<GmailPasswordScreen> createState() => _GmailPasswordScreenState();
}

class _GmailPasswordScreenState extends State<GmailPasswordScreen> {
  bool _obscureText = true;
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
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
            const Text(
              'Chào mừng',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(widget.email,
                style: const TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: _obscureText,
              decoration: InputDecoration(
                labelText: 'Nhập mật khẩu của bạn',
                labelStyle: const TextStyle(color: Colors.grey),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {},
              child: const Text('Thử cách khác',
                  style: TextStyle(color: Colors.blue)),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/welcome',
                    arguments: widget.email);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('Tiếp theo'),
            ),
          ],
        ),
      ),
    );
  }
}
