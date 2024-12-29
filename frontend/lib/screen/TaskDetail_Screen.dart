import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TaskDetailScreen extends StatefulWidget {
  final String taskId;

  TaskDetailScreen({required this.taskId});

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  Map<String, dynamic>? taskData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchTaskDetails();
  }

  Future<void> _fetchTaskDetails() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/task/${widget.taskId}'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        setState(() {
          taskData = jsonData['data']['list'];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Không thể tải task: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Lỗi: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(taskData?['name'] ?? 'Chi tiết Task'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tên Task: ${taskData?['name'] ?? 'Không có tên'}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Mô tả: ${taskData?['description'] ?? 'Không có mô tả'}',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Người tạo: ${taskData?['createdBy'] ?? 'Không rõ'}',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Trạng thái: ${taskData?['status'] ?? 'Không rõ'}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
    );
  }
}
