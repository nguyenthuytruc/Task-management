import 'dart:convert'; // Để parse JSON
import 'package:http/http.dart' as http;

class ApiListService {
  final String baseUrl = 'http://10.0.2.2:3000';

  // Lấy danh sách tất cả Lists
  Future<List<dynamic>> getAllLists(String boardId) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/api/list/b/$boardId'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        print('Response JSON: $json'); // In ra phản hồi để kiểm tra

        // Kiểm tra xem có dữ liệu không
        if (json.containsKey('data') && json['data']['list'] != null) {
          List<dynamic> list = json['data']['list'] as List<dynamic>;

          // Nếu danh sách trống, thông báo không có dữ liệu
          if (list.isEmpty) {
            return Future.error('Không có danh sách nào trong board.');
          } else {
            return list;
          }
        } else {
          return Future.error('Không tìm thấy dữ liệu trong phản hồi.');
        }
      } else {
        return Future.error('Không thể tải danh sách: ${response.statusCode}');
      }
    } catch (e) {
      return Future.error('Lỗi: $e');
    }
  }

  // Lấy thông tin chi tiết của một List
  Future<Map<String, dynamic>> getListById(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/list/$id'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Trả về thông tin List
      } else {
        return Future.error('Failed to load list: ${response.statusCode}');
      }
    } catch (e) {
      return Future.error('Error: $e');
    }
  }

  Future<Map<String, dynamic>> createList(Map<String, dynamic> listData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/list'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(listData),
      );

      if (response.statusCode < 300) {
        return jsonDecode(response.body); // Trả về thông tin List vừa tạo
      } else {
        return Future.error('Failed to create list: ${response.statusCode}');
      }
    } catch (e) {
      return Future.error('Error: $e');
    }
  }

  // Cập nhật List
  Future<Map<String, dynamic>> updateList(
      String id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/list/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  // Xóa List
  Future<bool> deleteList(String id) async {
    try {
      final response =
          await http.delete(Uri.parse('$baseUrl/api/list/delete/$id'));
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  // Get Arr List
  // Lấy danh sách tất cả Lists
  Future<List<dynamic>> getArrLists(String listId) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/api/list/arr-list/$listId'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        print('Response JSON: $json'); // In ra phản hồi để kiểm tra

        // Kiểm tra xem có dữ liệu không
        if (json.containsKey('data') && json['data'] != null) {
          List<dynamic> list = json['data'] as List<dynamic>;

          // Nếu danh sách trống, thông báo không có dữ liệu
          if (list.isEmpty) {
            return Future.error('Không có danh sách nào trong board.');
          } else {
            return list;
          }
        } else {
          return Future.error('Không tìm thấy dữ liệu trong phản hồi.');
        }
      } else {
        return Future.error('Không thể tải danh sách: ${response.statusCode}');
      }
    } catch (e) {
      return Future.error('Lỗi: $e');
    }
  }
}
