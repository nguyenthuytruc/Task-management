import 'package:flutter/material.dart';
import 'package:frontend/models/api_authService.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false; // Trạng thái loading
  String _emailErrorMessage = ""; // Thông báo lỗi cho email
  String _usernameErrorMessage = ""; // Thông báo lỗi cho email
  String _passwordErrorMessage = ""; // Thông báo lỗi cho password
  String _RegisterErrorMessage = ""; // Thông báo lỗi cho đăng nhập

  // Hàm kiểm tra định dạng email
  bool _isValidEmail(String email) {
    String pattern =
        r'^[a-zA-Z0-9._%+-]+@gmail\.com$'; // Kiểm tra email @gmail.com
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(email);
  }

  bool _isValidUsername(String username) {
    return username.length >= 6; // Username phải 6 kí t
  }

  // Hàm kiểm tra mật khẩu (tùy chỉnh theo yêu cầu)
  bool _isValidPassword(String password) {
    return password.length >= 6; // Mật khẩu phải dài ít nhất 6 ký tự
  }

  // Hàm đăng nhập
  void _register() async {
    setState(() {
      _isLoading = true; // Đặt trạng thái đang tải
      _emailErrorMessage = ""; // Reset thông báo lỗi email
      _usernameErrorMessage = "";
      _passwordErrorMessage = ""; // Reset thông báo lỗi password
      _RegisterErrorMessage = ""; // Reset thông báo lỗi đăng nhập
    });

    String email = _emailController.text;
    String username = _usernameController.text;
    String password = _passwordController.text;

    bool isEmailValid = _isValidEmail(email);
    bool isUsernameValid = _isValidUsername(email);
    bool isPasswordValid = _isValidPassword(password);

    // Kiểm tra email và mật khẩu
    if (!isEmailValid) {
      setState(() {
        _isLoading = false;
        _emailErrorMessage = "Email phải theo định dạng (example@gmail.com)!";
      });
      return;
    }

    if (!isPasswordValid) {
      setState(() {
        _isLoading = false;
        _passwordErrorMessage = "Password phải đủ 6 kí tự!";
      });
      return;
    }

    if (!isUsernameValid) {
      setState(() {
        _isLoading = false;
        _usernameErrorMessage = "Vui lòng nhập username";
      });
      return;
    }

    // Gọi API Register
    var response = await AuthService.register(email, username, password);

    setState(() {
      _isLoading = false; // Đặt lại trạng thái sau khi có kết quả từ API
    });

    if (response['isSuccess']) {
      // Nếu đăng nhập thành công
      print("Register successful");
      Navigator.pushReplacementNamed(
        context,
        '/',
      );
    } else {
      // Nếu đăng nhập thất bại
      print("Register failed");
      print(response);
      setState(() {
        _RegisterErrorMessage = response['message']; // Thông báo chung
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade300, Colors.blue.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Chào mừng bạn đến với QTV!",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Tiếp tục đăng ký",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: "Email",
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          errorText: _emailErrorMessage.isNotEmpty
                              ? _emailErrorMessage
                              : null,
                        ),
                      ),
                      SizedBox(height: 15),
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: "Username",
                          prefixIcon: Icon(Icons.verified_user),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          errorText: _usernameErrorMessage.isNotEmpty
                              ? _usernameErrorMessage
                              : null,
                        ),
                      ),
                      SizedBox(height: 15),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          errorText: _passwordErrorMessage.isNotEmpty
                              ? _passwordErrorMessage
                              : null,
                        ),
                      ),
                      SizedBox(height: 20),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: _register, // Gọi hàm đăng ký khi nhấn
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 30),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor:
                                  Colors.blue.shade700, // Màu nền nút đăng ký
                            ),
                            child: const Text(
                              "Đăng ký",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white, // Màu chữ
                              ),
                            ),
                          ),
                          const SizedBox(
                              height: 15), // Tăng khoảng cách giữa hai nút
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(
                                  context); // Trở lại màn hình trước đó
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 30),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor:
                                  Colors.grey.shade600, // Màu nền nút trở lại
                            ),
                            child: const Text(
                              "Trở lại",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white, // Màu chữ
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_emailErrorMessage.isNotEmpty ||
                          _passwordErrorMessage.isNotEmpty ||
                          _usernameErrorMessage.isNotEmpty ||
                          _RegisterErrorMessage.isNotEmpty) ...[
                        SizedBox(height: 10),
                        Text(
                          // _emailErrorMessage.isNotEmaaapty
                          //     ? _emailErrorMessage
                          //     : _passwordErrorMessage.isNotEmpty
                          //         ? _passwordErrorMessage
                          _RegisterErrorMessage,
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
