import 'package:flutter/material.dart';
import 'package:frontend/screen/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginScreen(), // Đặt LoginScreen làm màn hình chính
    );
  }
}
