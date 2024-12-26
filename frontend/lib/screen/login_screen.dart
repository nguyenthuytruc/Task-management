// import 'package:flutter/material.dart';
// import 'package:frontend/models/api_authService.dart';
// import 'package:frontend/screen/register_screen.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();

//   Future<void> saveLoginStatus() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('isLoggedIn', true);
//   }

//   bool _isLoading = false; // Trạng thái loading
//   String _emailErrorMessage = ""; // Thông báo lỗi cho email
//   String _passwordErrorMessage = ""; // Thông báo lỗi cho password
//   String _loginErrorMessage = ""; // Thông báo lỗi cho đăng nhập

//   // Hàm kiểm tra định dạng email
//   bool _isValidEmail(String email) {
//     String pattern =
//         r'^[a-zA-Z0-9._%+-]+@gmail\.com$'; // Kiểm tra email @gmail.com
//     RegExp regex = RegExp(pattern);
//     return regex.hasMatch(email);
//   }

//   // Hàm kiểm tra mật khẩu (tùy chỉnh theo yêu cầu)
//   bool _isValidPassword(String password) {
//     return password.length >= 6; // Mật khẩu phải dài ít nhất 6 ký tự
//   }

//   // Hàm đăng nhập
//   void _login() async {
//     setState(() {
//       _isLoading = true; // Đặt trạng thái đang tải
//       _emailErrorMessage = ""; // Reset thông báo lỗi email
//       _passwordErrorMessage = ""; // Reset thông báo lỗi password
//       _loginErrorMessage = ""; // Reset thông báo lỗi đăng nhập
//     });

//     String email = _emailController.text;
//     String password = _passwordController.text;

//     bool isEmailValid = _isValidEmail(email);
//     bool isPasswordValid = _isValidPassword(password);

//     // Kiểm tra email và mật khẩu
//     if (!isEmailValid) {
//       setState(() {
//         _isLoading = false;
//         _emailErrorMessage =
//             "Email phải theo định dạng (e.g. example@gmail.com)!";
//       });
//       return;
//     }

//     if (!isPasswordValid) {
//       setState(() {
//         _isLoading = false;
//         _passwordErrorMessage = "Password phải đủ 6 kí tự!";
//       });
//       return;
//     }

//     // Gọi API login
//     var response = await AuthService.login(email, password);

//     setState(() {
//       _isLoading = false; // Đặt lại trạng thái sau khi có kết quả từ API
//     });

//     if (response['isSuccess']) {
//       // Nếu đăng nhập thành công
//       print("Login successful");
//       String idUser = response['data']['user']['userExists']['_id'];
//       String token = response['data']['user']['token'];
//       print(token);
//       // Save login status
//       await saveLoginStatus();

//       // Navigate to board screen
//       Navigator.pushReplacementNamed(
//         context,
//         '/board',
//         arguments: idUser, // Truyền idUser vào BoardScreen
//       );
//     } else {
//       // Nếu đăng nhập thất bại
//       print("Login failed");
//       setState(() {
//         _loginErrorMessage =
//             "Sai mật khẩu hoặc email! Vui lòng nhập lại!"; // Thông báo chung
//       });

//       // Show SnackBar for error after the build phase
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'Đăng nhập thất bại! Vui lòng thử lại.',
//               style: TextStyle(color: Colors.white),
//             ),
//             backgroundColor: Colors.red,
//           ),
//         );
//       });
//     }
//   }

//   void _redirectRegister() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => RegisterScreen(),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.blue.shade300, Colors.blue.shade700],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: Center(
//           child: SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.all(20.0),
//               child: Card(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 elevation: 5,
//                 child: Padding(
//                   padding: const EdgeInsets.all(20.0),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(
//                         "Chào mừng bạn đến với QTV!",
//                         style: TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.blue.shade700,
//                         ),
//                       ),
//                       SizedBox(height: 10),
//                       Text(
//                         "Tiếp tục đăng nhập",
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.grey.shade600,
//                         ),
//                       ),
//                       SizedBox(height: 20),
//                       TextField(
//                         controller: _emailController,
//                         decoration: InputDecoration(
//                           labelText: "Email",
//                           prefixIcon: Icon(Icons.email),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           errorText: _emailErrorMessage.isNotEmpty
//                               ? _emailErrorMessage
//                               : null,
//                         ),
//                       ),
//                       SizedBox(height: 15),
//                       TextField(
//                         controller: _passwordController,
//                         obscureText: true,
//                         decoration: InputDecoration(
//                           labelText: "Mật khẩu",
//                           prefixIcon: Icon(Icons.lock),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           errorText: _passwordErrorMessage.isNotEmpty
//                               ? _passwordErrorMessage
//                               : null,
//                         ),
//                       ),
//                       SizedBox(height: 20),
//                       _isLoading
//                           ? CircularProgressIndicator()
//                           : ElevatedButton(
//                               onPressed: () async {
//                                 // Chuyển đến trang chủ
//                                 await saveLoginStatus();
//                                 _login();
//                               },
//                               style: ElevatedButton.styleFrom(
//                                 padding: EdgeInsets.symmetric(
//                                     vertical: 12, horizontal: 30),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                                 backgroundColor: Colors.blue
//                                     .shade700, // Thay primary bằng backgroundColor
//                               ),
//                               child: Text(
//                                 "Đăng nhập",
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                       SizedBox(height: 15),
//                       ElevatedButton(
//                         onPressed: () async {
//                           // Chuyển đến trang đăng ký
//                           _redirectRegister();
//                         },
//                         style: ElevatedButton.styleFrom(
//                           padding: EdgeInsets.symmetric(
//                               vertical: 12, horizontal: 30),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           backgroundColor: Colors.greenAccent
//                               .shade700, // Thay primary bằng backgroundColor
//                         ),
//                         child: Text(
//                           "Đăng ký",
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       if (_emailErrorMessage.isNotEmpty ||
//                           _passwordErrorMessage.isNotEmpty ||
//                           _loginErrorMessage.isNotEmpty) ...[
//                         SizedBox(height: 10),
//                         Text(
//                           _loginErrorMessage,
//                           style: TextStyle(color: Colors.red),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:frontend/models/api_authService.dart';
import 'package:frontend/screen/register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> saveLoginStatus(String idUser) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('idUser', idUser); // Lưu idUser
    await prefs.setBool('isLoggedIn', true);
  }

  bool _isLoading = false;
  String _emailErrorMessage = "";
  String _passwordErrorMessage = "";
  String _loginErrorMessage = "";

  bool _isValidEmail(String email) {
    String pattern =
        r'^[a-zA-Z0-9._%+-]+@gmail\.com$'; // Kiểm tra email @gmail.com
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(email);
  }

  bool _isValidPassword(String password) {
    return password.length >= 6; // Mật khẩu phải dài ít nhất 6 ký tự
  }

  void _login() async {
    setState(() {
      _isLoading = true;
      _emailErrorMessage = "";
      _passwordErrorMessage = "";
      _loginErrorMessage = "";
    });

    String email = _emailController.text;
    String password = _passwordController.text;

    bool isEmailValid = _isValidEmail(email);
    bool isPasswordValid = _isValidPassword(password);

    if (!isEmailValid) {
      setState(() {
        _isLoading = false;
        _emailErrorMessage =
            "Email phải theo định dạng (e.g. example@gmail.com)!";
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

    var response = await AuthService.login(email, password);

    setState(() {
      _isLoading = false;
    });

    if (response['isSuccess']) {
      print("Login successful");
      String idUser = response['data']['user']['userExists']['_id'];
      print(idUser);
      String token = response['data']['user']['token'];
      print(token);
      await saveLoginStatus(idUser);

      Navigator.pushReplacementNamed(
        context,
        '/board',
        arguments: idUser,
      );
    } else {
      print("Login failed");
      setState(() {
        _loginErrorMessage = response['message'] ??
            "Sai mật khẩu hoặc email! Vui lòng nhập lại!";
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _loginErrorMessage,
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }

  void _redirectRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterScreen(),
      ),
    );
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
                        "Tiếp tục đăng nhập",
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
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Mật khẩu",
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
                      _isLoading
                          ? CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: () {
                                _login();
                              },
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 30),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: Colors.blue.shade700,
                              ),
                              child: Text(
                                "Đăng nhập",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                      SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: _redirectRegister,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.greenAccent.shade700,
                        ),
                        child: Text(
                          "Đăng ký",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (_loginErrorMessage.isNotEmpty) ...[
                        SizedBox(height: 10),
                        Text(
                          _loginErrorMessage,
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
