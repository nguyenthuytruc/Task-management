import 'dart:convert'; // Để parse JSON
import 'package:http/http.dart' as http;

class ApiNoteService {
  final String baseUrl = 'http://10.0.2.2:3000';

  // Helper function để xử lý HTTP GET request
  Future<Map<String, dynamic>> _getRequest(String endpoint) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl$endpoint'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('GET Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('GET Exception: $e');
      throw Exception('Error: $e');
    }
  }

  // Helper function để xử lý HTTP POST request
  Future<Map<String, dynamic>> _postRequest(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print('POST Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to create data: ${response.statusCode}');
      }
    } catch (e) {
      print('POST Exception: $e');
      throw Exception('Error: $e');
    }
  }

  // Helper function để xử lý HTTP PUT request
  Future<bool> _putRequest(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('PUT Error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('PUT Exception: $e');
      return false;
    }
  }

  // Helper function để xử lý HTTP DELETE request
  Future<bool> _deleteRequest(String endpoint) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl$endpoint'));

      if (response.statusCode == 200) {
        return true;
      } else {
        print('DELETE Error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('DELETE Exception: $e');
      return false;
    }
  }

  // Lấy tất cả Note theo ID Board
  Future<List<dynamic>> getNotesByBoardId(String idBoard) async {
    try {
      final response = await _getRequest('/api/notes?boardId=$idBoard');

      if (response['data'] != null && response['data']['list'] != null) {
        return response['data']['list'];
      } else {
        print('No notes found for board ID: $idBoard');
        return [];
      }
    } catch (e) {
      print('Error fetching notes by board ID: $e');
      throw Exception('Error: $e');
    }
  }

  // Lấy tất cả Note theo ID User
  Future<List<dynamic>> getNotesByUserId(String idUser) async {
    try {
      final response = await _getRequest('/api/notes/user/$idUser');
      return response['data']['list'] ?? [];
    } catch (e) {
      print('Error fetching notes by user ID: $e');
      throw Exception('Error: $e');
    }
  }

  // Lấy chi tiết một Note theo ID
  Future<Map<String, dynamic>> getNoteById(String id) async {
    return await _getRequest('/api/notes/$id');
  }

  // Cập nhật một Note
  Future<bool> updateNoteById(String id, Map<String, dynamic> data) async {
    return await _putRequest('/api/notes/$id', data);
  }

  // Xóa một Note
  Future<bool> deleteNoteById(String id) async {
    return await _deleteRequest('/api/notes/$id');
  }

  // Tạo mới một Note
  Future<Map<String, dynamic>> createNote(Map<String, dynamic> noteData) async {
    try {
      final response = await _postRequest('/api/notes', noteData);

      if (response['data'] != null) {
        return response['data'];
      } else {
        throw Exception('Unexpected response format: $response');
      }
    } catch (e) {
      print('Error creating note: $e');
      throw Exception('Error: $e');
    }
  }

  // Cập nhật trạng thái của một Note
  Future<bool> updateNoteStatus(String id, bool status) async {
    return await _putRequest('/api/notes/updateStatus/$id', {'status': status});
  }
}
