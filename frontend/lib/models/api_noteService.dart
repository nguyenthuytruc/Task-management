import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/models/Note.dart';

class ApiNoteService {
  final String baseUrl = "http://10.0.2.2:3000";

  // Lấy danh sách ghi chú theo boardId
  Future<List<Note>> getNotesByBoardId(String boardId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/notes/b/$boardId'));

    if (response.statusCode == 200) {
      final List<dynamic> noteList = json.decode(response.body)["data"]["list"];
      return noteList.map((note) => Note.fromJson(note)).toList();
    } else {
      throw Exception("Không thể tải ghi chú cho board này");
    }
  }

  // Tạo ghi chú mới
  Future<bool> createNote(Map<String, dynamic> noteData) async {
    try {
      // Gọi API và gửi noteData dưới dạng JSON
      var response = await http.post(
        Uri.parse('$baseUrl/api/notes'),
        body: jsonEncode(noteData),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Tạo ghi chú thất bại');
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  // Cập nhật trạng thái ghi chú
  Future<bool> updateNoteStatus(String id) async {
    final response = await http.put(Uri.parse("$baseUrl/updateStatus/$id"));

    return response.statusCode == 200;
  }

  // Cập nhật ghi chú
  Future<bool> updateNote(Note note) async {
    final response = await http.put(
      Uri.parse("$baseUrl/api/notes/${note.id}"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(note.toJson()),
    );
    
    return response.statusCode == 200;
  }

  // Xóa ghi chú theo id
  Future<bool> deleteNoteById(String id) async {
    final response = await http.delete(Uri.parse("$baseUrl/api/notes/delete/$id"));

    return response.statusCode == 200;
  }
}
