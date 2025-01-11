import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/models/TaskModel.dart';

class ApiTaskService {
  final String baseUrl = 'http://10.0.2.2:3000';

  // Lấy danh sách tất cả Task
  Future<List<TaskModel>> getAllTasks() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/task/'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);

        // Kiểm tra xem có dữ liệu không
        if (json.containsKey('data') && json['data']['list'] != null) {
          List<dynamic> list = json['data']['list'] as List<dynamic>;

          return list.map((taskJson) => TaskModel.fromJson(taskJson)).toList();
        } else {
          return Future.error('Không có task nào.');
        }
      } else {
        return Future.error('Không thể tải danh sách task: ${response.statusCode}');
      }
    } catch (e) {
      return Future.error('Lỗi: $e');
    }
  }
  Future<bool> moveTask(String taskId, String newListId, String newBoardId) async {
  final response = await http.post(
    Uri.parse('$baseUrl/api/task/move/$taskId'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'taskId': taskId,
      'newListId': newListId,
      'newBoardId': newBoardId,
    }),
  );

  if (response.statusCode == 200) {
    return true;
  } else {
    throw Exception('Lỗi khi di chuyển task');
  }
}

  // Lấy danh sách tất cả Task theo ID của List
Future<List<dynamic>> getAllTasksByListId(String idList) async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/api/task/l/$idList')); // Sửa URL đúng với route
    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);

      // Kiểm tra xem có dữ liệu không
      if (json.containsKey('data') && json['data']['list'] != null) {
        List<dynamic> list = json['data']['list'] as List<dynamic>;

        if (list.isEmpty) {
          return Future.error('Không có task nào trong list này.');
        } else {
          return list;
        }
      } else {
        return Future.error('Không tìm thấy dữ liệu trong phản hồi.');
      }
    } else {
      return Future.error('Không thể tải task: ${response.statusCode}');
    }
  } catch (e) {
    return Future.error('Lỗi: $e');
  }
}

  // Lấy thông tin task theo ID
Future<Map<String, dynamic>> getTaskById(String id) async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/api/task/$id')); // Sửa URL đúng với route

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return Future.error('Không thể tải task: ${response.statusCode}');
    }
  } catch (e) {
    return Future.error('Lỗi: $e');
  }
}

Future<List<dynamic>> getBoardMembers(String boardId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/board/$boardId/members'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);

        // Kiểm tra xem có dữ liệu không
        if (json.containsKey('data') && json['data']['list'] != null) {
          return json['data']['list'] as List<dynamic>;
        } else {
          return Future.error('Không tìm thấy thành viên nào trong board này.');
        }
      } else {
        return Future.error('Không thể tải danh sách thành viên: ${response.statusCode}');
      }
    } catch (e) {
      return Future.error('Lỗi: $e');
    }
  }
  /// Tạo một task mới
Future<Map<String, dynamic>> createTask(Map<String, dynamic> taskData) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/api/task'), // Sửa URL đúng với route
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(taskData),
    );

    if (response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      return Future.error('Failed to create task: ${response.statusCode}');
    }
  } catch (e) {
    return Future.error('Error: $e');
  }
}

// Cập nhật task theo ID
Future<Map<String, dynamic>> updateTask(String id, Map<String, dynamic> data) async {
  try {
    final response = await http.put(
      Uri.parse('$baseUrl/api/task/$id'), // Sửa URL đúng với route
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      return Future.error('Failed to update task: ${response.statusCode}');
    }
  } catch (e) {
    return Future.error('Error: $e');
  }
}


 // Xóa task theo ID
Future<bool> deleteTask(String id) async {
  try {
    final response = await http.delete(Uri.parse('$baseUrl/api/task/delete/$id')); // Sửa URL đúng với route
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
// Đăng ký email cho task theo ID
Future<void> registerEmail(String id, String email) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/api/task/register/$id'), // Sửa URL đúng với route
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode != 200) {
      return Future.error('Failed to register email: ${response.statusCode}');
    }
  } catch (e) {
    return Future.error('Error: $e');
  }
}

}
