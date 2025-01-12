// ignore_for_file: avoid_print

import 'dart:convert'; // Để parse JSON
import 'package:http/http.dart' as http;

class ApiBoardService {
  final String baseUrl = 'http://10.0.2.2:3000';

  // Lấy danh sách tất cả Boards
  Future<List<dynamic>> getAllBoards(String idUser) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/api/board/getAll/$idUser'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);

        if (json.containsKey('data')) {
          List<dynamic> list = json['data']['list'] as List<dynamic>;
          if (list.isEmpty) {
            return [];
          } else {
            return list;
          }
        } else {
          throw Exception('Key "list" not found in response.');
        }
      } else {
        throw Exception('Failed to load boards: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Lấy danh sách tất cả Coop Board (mình là member)
  Future<List<dynamic>> getAllBoardsCoop(String idUser) async {
    try {
      print("Get Coop");
      final response =
          await http.get(Uri.parse('$baseUrl/api/board/c/$idUser'));
      print(idUser);
      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);

        if (json.containsKey('data')) {
          List<dynamic> list = json['data']['list'] as List<dynamic>;
          if (list.isEmpty) {
            return [];
          } else {
            return list;
          }
        } else {
          throw Exception('Key "list" not found in response.');
        }
      } else {
        throw Exception('Failed to load boards: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Lấy thông tin chi tiết của một Board
  Future<Map<String, dynamic>> getBoardById(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/board/$id'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Trả về thông tin Board
      } else {
        throw Exception('Failed to load board: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Thêm thành viên vào Board
  Future<bool> addMembers(String boardId, String members) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/board/$boardId/add-members'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': members}),
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 400) {
        throw Exception("Không tìm thấy email");
      }
      return false;
    } catch (e) {
      throw Exception('$e');
    }
  }

  // Xóa thành viên khỏi Board
  Future<bool> removeMembers(String boardId, List<String> members) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/board/$boardId/remove-members'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'members': members}),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to remove members: $e');
    }
  }

  // Cập nhật Board
  Future<bool> updateBoard(String boardId, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/board/$boardId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      print(response.body);
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to update board: $e');
    }
  }

  // Xóa Board
  Future<bool> deleteBoard(String boardId) async {
    try {
      final response =
          await http.delete(Uri.parse('$baseUrl/api/board/delete/$boardId'));

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to delete board: $e');
    }
  }

  // Tạo mới Board
  Future<Map<String, dynamic>> createBoard(
      Map<String, dynamic> boardData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/board'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(boardData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body); // Trả về thông tin Board vừa tạo
      } else {
        throw Exception('Failed to create board: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
