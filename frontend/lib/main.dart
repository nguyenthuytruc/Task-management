import 'package:flutter/material.dart';
import 'package:frontend/screen/board_screen.dart';
import 'package:frontend/screen/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/', // Màn hình đầu tiên khi mở ứng dụng
      routes: {
        '/': (context) => LoginScreen(), // Đăng nhập
        '/board': (context) => BoardScreen(), // Điều hướng tới màn hình Board
      },
    );
  }
}
