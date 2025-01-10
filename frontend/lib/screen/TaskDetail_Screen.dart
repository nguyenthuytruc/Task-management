import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    _fetchTaskDetails();
    _loadDates(); // Đảm bảo gọi _loadDates trong initState
  }

  // Hàm tải chi tiết task
  Future<void> _fetchTaskDetails() async {
  try {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:3000/api/task/${widget.taskId}'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      setState(() {
        taskData = jsonData['data']['list'];
        // Chắc chắn sử dụng dữ liệu từ API nếu có, hoặc từ SharedPreferences
        startDate = taskData?['startDate'] != null
            ? DateTime.parse(taskData?['startDate'])
            : startDate;
        endDate = taskData?['endDate'] != null
            ? DateTime.parse(taskData?['endDate'])
            : endDate;
        isLoading = false;
      });
      await _loadDates(); // Tải thêm ngày từ SharedPreferences nếu có
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


  Future<void> _updateTask() async {
    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:3000/api/task/${widget.taskId}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': taskData?['name'],
          'description': taskData?['description'],
          'startDate': startDate?.toIso8601String(),
          'endDate': endDate?.toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cập nhật Task thành công')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Không thể cập nhật Task: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi cập nhật Task: $e')),
      );
    }
  }

  Future<void> _loadDates() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? startDateStr = prefs.getString('startDate');
    String? endDateStr = prefs.getString('endDate');

    setState(() {
      startDate = startDateStr != null ? DateTime.parse(startDateStr) : null;
      endDate = endDateStr != null ? DateTime.parse(endDateStr) : null;
    });
  }

Future<void> _saveDates() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (startDate != null) {
      prefs.setString('startDate', startDate!.toIso8601String());
    }
    if (endDate != null) {
      prefs.setString('endDate', endDate!.toIso8601String());
    }
  }

  // Hàm hiển thị picker ngày
  void _showDatePicker(bool isStartDate) {
    DateTime? tempDate = isStartDate ? startDate : endDate;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isStartDate ? 'Chọn ngày bắt đầu' : 'Chọn ngày kết thúc',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              SizedBox(
                height: 300, // Đặt chiều cao cố định cho picker
                child: SfDateRangePicker(
                  initialSelectedDate: tempDate ?? DateTime.now(),
                  onSelectionChanged:
                      (DateRangePickerSelectionChangedArgs args) {
                    if (args.value is DateTime) {
                      tempDate = args.value;
                    }
                  },
                  selectionMode: DateRangePickerSelectionMode.single,
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.pop(context), // Đóng bottom sheet
                    child: Text('Đóng'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (isStartDate) {
                          startDate = tempDate;
                        } else {
                          endDate = tempDate;
                        }
                      });
                      _saveDates(); // Lưu ngày đã chọn
                      Navigator.pop(context); // Đóng bottom sheet
                    },
                    child: Text('Chọn'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(taskData?['name'] ?? 'Chi tiết Task'),
      backgroundColor: Colors.deepPurple, // Thêm màu nền cho appBar
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              _showEditDialog(); // Hiển thị hộp thoại chỉnh sửa
            } else if (value == 'delete') {
              _deleteTask(); // Xóa task
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 8),
                    Text('Chỉnh sửa'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18),
                    SizedBox(width: 8),
                    Text('Xóa'),
                  ],
                ),
              ),
            ];
          },
        ),
      ],
    ),
    body: isLoading
        ? Center(child: CircularProgressIndicator())
        : errorMessage != null
            ? Center(child: Text(errorMessage!, style: TextStyle(fontSize: 16, color: Colors.red)))
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tên Task: ${taskData?['name']}',
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                              ),
                              SizedBox(height: 10),
                              Text(
                                  'Mô tả: ${taskData?['description'] ?? 'Không có mô tả'}',
                                  style: TextStyle(fontSize: 16, color: Colors.black54)),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Ngày bắt đầu: ${startDate != null ? DateFormat('dd/MM/yyyy').format(startDate!) : 'Chưa chọn'}',
                                    style: TextStyle(fontSize: 16, color: Colors.black87),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.edit_calendar, color: Colors.deepPurple),
                                    onPressed: () => _showDatePicker(true),
                                  ),
                                ],
                              ),
                              Divider(color: Colors.black38),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Ngày kết thúc: ${endDate != null ? DateFormat('dd/MM/yyyy').format(endDate!) : 'Chưa chọn'}',
                                    style: TextStyle(fontSize: 16, color: Colors.black87),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.edit_calendar, color: Colors.deepPurple),
                                    onPressed: () => _showDatePicker(false),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
  );
}

  void _showEditDialog() {
    // Mở dialog để chỉnh sửa task
    showDialog(
      context: context,
      builder: (context) {
        String updatedName = taskData?['name'] ?? '';
        String updatedDescription = taskData?['description'] ?? '';

        return AlertDialog(
          title: Text('Chỉnh sửa Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Tên Task'),
                controller: TextEditingController(text: updatedName),
                onChanged: (value) => updatedName = value,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Mô tả Task'),
                controller: TextEditingController(text: updatedDescription),
                onChanged: (value) => updatedDescription = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  final response = await http.put(
                    Uri.parse('http://10.0.2.2:3000/api/task/${widget.taskId}'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({
                      'name': updatedName,
                      'description': updatedDescription,
                    }),
                  );

                  if (response.statusCode == 200) {
                    setState(() {
                      taskData?['name'] = updatedName;
                      taskData?['description'] = updatedDescription;
                    });
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Không thể chỉnh sửa task: ${response.statusCode}')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi khi chỉnh sửa task: $e')),
                  );
                }
              },
              child: Text('Lưu'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteTask() async {
    try {
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:3000/api/task/delete/${widget.taskId}'),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context); // Quay lại màn hình trước đó
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể xóa task: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xóa task: $e')),
      );
    }
  }
}
