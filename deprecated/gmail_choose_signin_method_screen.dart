import 'package:flutter/material.dart';

class GmailChooseSignInMethodScreen extends StatelessWidget {
  final String email;

  GmailChooseSignInMethodScreen({required this.email});

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
            SizedBox(height: 16),
            Text('Chọn cách bạn muốn đăng nhập:',
                style: TextStyle(fontSize: 18)),
            ListTile(
              leading: Icon(Icons.lock, color: Colors.blue),
              title: Text('Nhập mật khẩu của bạn'),
              onTap: () {
                Navigator.pushNamed(context, '/password', arguments: email);
              },
            ),
            ListTile(
              leading: Icon(Icons.security, color: Colors.blue),
              title: Text('Sử dụng khoá truy cập của bạn'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.help, color: Colors.blue),
              title: Text('Nhận trợ giúp'),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
