// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:frontend/screen/board_screen.dart';
import 'package:frontend/screen/dashboard_screen.dart';
import 'package:frontend/screen/login_screen.dart';
import 'package:frontend/screen/register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Kiểm tra trạng thái đăng nhập từ SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final String idUser = prefs.getString('idUser') ?? "";
  print(idUser);
  // Ghi lỗi Flutter vào console
  FlutterError.onError = (FlutterErrorDetails details) {
    // Ghi lại lỗi và thông tin chi tiết
    print('Flutter error occurred: ${details.toString()}');
  };

  // Khởi động ứng dụng sau khi kiểm tra trạng thái đăng nhập
  runApp(MainApp(isLoggedIn: isLoggedIn));
}

class MainApp extends StatelessWidget {
  final bool isLoggedIn;

  const MainApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Tắt banner debug
      initialRoute: isLoggedIn
          ? '/dashboard'
          : '/', // Chọn route ban đầu dựa trên trạng thái đăng nhập
      routes: {
        '/': (context) => LoginScreen(), // Đăng nhập
        '/register': (context) => RegisterScreen(), // Đăng ký
        '/board': (context) => BoardScreen(),
        '/dashboard': (context) =>
            DashboardScreen(), // Màn hình chính sau khi đăng nhập thành công
      },
    );
  }
}
