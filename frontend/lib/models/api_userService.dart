// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// class ApiUserService {
//   final String baseUrl =
//       "http://10.0.2.2:3000"; // Thay bằng URL thực tế của backend

//   // Đăng nhập
//   Future<Map<String, dynamic>> login(String email, String password) async {
//     final response = await http.post(
//       Uri.parse("$baseUrl/login"),
//       body: json.encode({
//         'email': email,
//         'password': password,
//       }),
//       headers: {'Content-Type': 'application/json'},
//     );

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       await _saveToken(data['token']);
//       return data;
//     } else {
//       throw Exception("Login failed");
//     }
//   }

//   // Đăng ký
//   Future<Map<String, dynamic>> register(
//       String email, String username, String password) async {
//     final response = await http.post(
//       Uri.parse("$baseUrl/register"),
//       body: json.encode({
//         'email': email,
//         'username': username,
//         'password': password,
//       }),
//       headers: {'Content-Type': 'application/json'},
//     );

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       await _saveToken(data['token']);
//       return data;
//     } else {
//       throw Exception("Registration failed");
//     }
//   }

//   // Lưu token vào SharedPreferences
//   Future<void> _saveToken(String token) async {
//     final prefs = await SharedPreferences.getInstance();
//     prefs.setString('token', token);
//   }

//   // Lấy token từ SharedPreferences
//   Future<String?> getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('token');
//   }

//   // Lấy thông tin người dùng
//   Future<Map<String, dynamic>> getUserInfo(String userId) async {
//     final token = await getToken();
//     final response = await http.get(
//       Uri.parse("$baseUrl/$userId"),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token'
//       },
//     );

//     if (response.statusCode == 200) {
//       return json.decode(response.body);
//     } else {
//       throw Exception("Failed to fetch user data");
//     }
//   }

//   // Lấy tất cả người dùng
//   Future<List<Map<String, dynamic>>> getAllUsers() async {
//     final token = await getToken();
//     final response = await http.get(
//       Uri.parse("$baseUrl/"),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token'
//       },
//     );

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       return List<Map<String, dynamic>>.from(data);
//     } else {
//       throw Exception("Failed to load users");
//     }
//   }

//   // Cập nhật thông tin người dùng (ví dụ như ảnh đại diện)
//   Future<Map<String, dynamic>> updateUserInfo(
//       String userId, Map<String, dynamic> updates) async {
//     final token = await getToken();
//     final response = await http.put(
//       Uri.parse("$baseUrl/$userId"),
//       body: json.encode(updates),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token'
//       },
//     );

//     if (response.statusCode == 200) {
//       return json.decode(response.body);
//     } else {
//       throw Exception("Failed to update user information");
//     }
//   }
// }
