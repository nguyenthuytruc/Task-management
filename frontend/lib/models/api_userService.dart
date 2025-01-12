import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  // API base url
  final String apiUrl =
      'http://10.0.2.2:3000/api'; // Sửa với URL thực tế của backend

  // Lấy thông tin người dùng theo ID
  Future<Map<String, dynamic>?> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString(
        'idUser'); // Đảm bảo userId lưu vào SharedPreferences sau khi đăng nhập thành công

    if (userId == null) {
      return null; // Nếu không có userId, không lấy được thông tin người dùng
    }

    final response = await http.get(
      Uri.parse('$apiUrl/users/$userId'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['data']
          ['user']; // Trả về dữ liệu người dùng từ API
    } else {
      throw Exception('Failed to load user data');
    }
  }

  // Lấy thông tin người dùng theo ID
  Future<List<dynamic>> getNoti() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString(
        'idUser'); // Đảm bảo userId lưu vào SharedPreferences sau khi đăng nhập thành công

    if (userId == null) {
      return []; // Nếu không có userId, không lấy được thông tin người dùng
    }

    final response = await http.get(
      Uri.parse('$apiUrl/users/noti/$userId'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['data']
          ['list']; // Trả về dữ liệu người dùng từ API
    } else {
      throw Exception('Failed to load user data');
    }
  }
}
