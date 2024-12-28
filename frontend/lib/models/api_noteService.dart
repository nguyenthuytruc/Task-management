import 'dart:convert';
import 'package:http/http.dart' as http;
import 'Note.dart';

class ApiNoteService {
  final String baseUrl = 'http://10.0.2.2:3000';

  // Lấy tất cả ghi chú
  Future<List<Note>> getAllNotes() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/notes'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        if (json.containsKey('data')) {
          List<dynamic> list = json['data']['list'] as List<dynamic>;
          if (list.isEmpty) {
            return [];
          } else {
            return list.map((note) => Note.fromJson(note)).toList();
          }
        } else {
          throw Exception('Key "list" not found in response.');
        }
      } else {
        throw Exception('Failed to load notes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Thêm ghi chú mới
  Future<Note> createNote(Note note) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/notes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(note.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return Note.fromJson(json['data']);
      } else {
        throw Exception('Failed to create note: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Cập nhật trạng thái ghim của ghi chú
  Future<bool> updateStatus(String noteId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/updateStatus/$noteId'),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to update note status: $e');
    }
  }

  // Xóa ghi chú
  Future<bool> deleteNote(String noteId) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/delete/$noteId'));

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to delete note: $e');
    }
  }
}
