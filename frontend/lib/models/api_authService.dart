import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl =
      "http://10.0.2.2:3000"; // Sử dụng 10.0.2.2 cho Android Emulator

  // Function for login
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final String apiUrl = "$baseUrl/api/auth/login";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email.trim(),
          "password": password.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body); // Chuyển JSON thành Map
        print(result);

        // Truy cập vào các trường trong JSON
        final data = result['data']; // Dữ liệu trả về
        final isSuccess = result['isSuccess']; // Trạng thái thành công
        final message = result['message']; // Thông báo từ backend

        if (isSuccess) {
          print("Đăng nhập thành công: $data");
          return result; // Trả về dữ liệu nếu cần
        } else {
          print("Đăng nhập thất bại: $message");
          throw Exception(message); // Ném lỗi với thông báo
        }
      } else {
        return {
          "success": false,
          "message": "Error: ${response.statusCode} - ${response.body}"
        };
      }
    } catch (e) {
      return {"success": false, "message": "An error occurred: $e"};
    }
  }
}
