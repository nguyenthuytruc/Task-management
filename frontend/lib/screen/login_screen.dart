// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:frontend/models/api_authService.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false; // Trạng thái loading
  String _errorMessage = ""; // Thông báo lỗi

  // Hàm đăng nhập
  void _login() async {
    setState(() {
      _isLoading = true; // Đặt trạng thái đang tải
      _errorMessage = ""; // Reset thông báo lỗi
    });

    String email = _emailController.text;
    String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _isLoading = false; // Đặt lại trạng thái khi kiểm tra không hợp lệ
        _errorMessage = "Please enter both email and password.";
      });
      return;
    }

    var response = await AuthService.login(email, password);

    setState(() {
      _isLoading = false; // Đặt lại trạng thái sau khi có kết quả từ API
    });

    if (response['isSuccess']) {
      print("Dang nhap thanh cong");
      String idUser = response['data']['user']['userExists']['_id'];
      String token = response['data']['user']['token'];
      print(token);
      Navigator.pushReplacementNamed(
        context,
        '/board',
        arguments: idUser, // Truyền idUser vào BoardScreen
      );
    } else {
      print("Dang nhap that bai");
      setState(() {
        _errorMessage =
            response['message'] ?? "Login failed. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: const EdgeInsets.only(left: 2),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.start, // Căn chỉnh phần tử từ trên cùng
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Email",
                errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
              ),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
              ),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator() // Khi đang tải, hiển thị loading
                : ElevatedButton(
                    onPressed: _login,
                    child: Text("Login"),
                  ),
            if (_errorMessage.isNotEmpty) ...[
              SizedBox(height: 10),
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
