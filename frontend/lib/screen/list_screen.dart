import 'package:flutter/material.dart';
import 'package:frontend/models/api_TaskService.dart';
import 'package:frontend/models/api_listService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListScreen extends StatefulWidget {
  final String boardId;

  // Constructor nhận boardId
  ListScreen({required this.boardId});

  @override
  _ListScreenState createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final ApiListService _apiListService = ApiListService();
  final ApiTaskService _apiTaskService = ApiTaskService();
  late Future<List<dynamic>> _lists; // Future chứa danh sách các List của Board
  late String _userId; // Biến để lưu idUser

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Gọi API để lấy danh sách các List của Board khi màn hình được load
    _getUserId();
    _lists =
        _apiListService.getAllLists(widget.boardId); // Truyền boardId vào API
  }

  Future<void> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId =
          prefs.getString('idUser') ?? ''; // Lấy idUser từ SharedPreferences
    });
  }

  Future<List<dynamic>> _getTasksForList(String listId) async {
    try {
      return await _apiTaskService.getAllTasksByListId(listId); // Gọi API để lấy task theo listId
    } catch (e) {
      print('Error fetching tasks: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue, // Toàn bộ nền màu xanh
      appBar: AppBar(
        title: Text('Danh sách của bạn'),
        backgroundColor: Colors.blueAccent, // Đổi màu thanh AppBar
      ),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: FutureBuilder<List<dynamic>>(
              future: _lists,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Lỗi: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("Không có danh sách nào."));
                } else {
                  var lists = snapshot.data!;
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: lists.length,
                    itemBuilder: (context, index) {
                      var list = lists[index];
                      return Container(
                        width: 200,
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        child: Card(
                          color: Colors.white,
                          elevation: 3,
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        list['name'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      icon: Icon(Icons.more_horiz),
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          _showEditListDialog(list);
                                        } else if (value == 'delete') {
                                          _showDeleteConfirmationDialog(
                                              list['_id']);
                                        }
                                      },
                                      itemBuilder: (BuildContext context) => [
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: Text('Chỉnh sửa'),
                                        ),
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Text('Xóa'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Text(
                                  list['description'] ?? 'Không có mô tả',
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                // Hiển thị các task dưới mỗi list
                                FutureBuilder<List<dynamic>>(
                                  future: _getTasksForList(list['_id']),
                                  builder: (context, taskSnapshot) {
                                    if (taskSnapshot.connectionState == ConnectionState.waiting) {
                                      return CircularProgressIndicator();
                                    } else if (taskSnapshot.hasError) {
                                      return Text('Lỗi: ${taskSnapshot.error}');
                                    } else if (!taskSnapshot.hasData || taskSnapshot.data!.isEmpty) {
                                      return Text('Không có task nào.');
                                    } else {
                                      var tasks = taskSnapshot.data!;
                                      return ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: tasks.length,
                                        itemBuilder: (context, taskIndex) {
                                          var task = tasks[taskIndex];
                                          return ListTile(
                                            title: Text(task['name']),
                                            subtitle: Text(task['description'] ?? 'Không có mô tả'),
                                          );
                                        },
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Hiển thị hộp thoại thêm danh sách mới
  void _showAddListDialog() {
    String newListName = "";
    String newListDescription = "";

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Thêm danh sách mới"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: "Tên danh sách",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  newListName = value;
                },
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  labelText: "Mô tả (không bắt buộc)",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  newListDescription = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Đóng hộp thoại
              },
              child: Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (newListName.isNotEmpty) {
                  await _addNewList(
                      newListName, newListDescription); // Gọi API để thêm
                  Navigator.pop(context); // Đóng hộp thoại
                  setState(() {
                    _lists = _apiListService
                        .getAllLists(widget.boardId); // Làm mới danh sách
                  });
                }
              },
              child: Text("Thêm"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addNewList(String name, String description) async {
    try {
      final listData = {
        'name': name,
        'description': description,
        'boardId': widget.boardId,
        'createdBy': _userId, // Sử dụng idUser khi tạo danh sách
      };

      final newList = await _apiListService.createList(listData);

      // In phản hồi từ API để kiểm tra
      print('API response: $newList');

      // Kiểm tra nếu có dữ liệu hợp lệ từ API
      if (newList != null && newList['data'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tạo danh sách mới thành công!')),
        );
      } else {
        // Nếu không có dữ liệu hợp lệ từ API, hiển thị thông báo lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Thêm danh sách thất bại: Không có dữ liệu trả về')),
        );
      }
    } catch (e) {
      // In ra chi tiết lỗi để debug
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thêm danh sách thất bại: $e')),
      );
    }
  }
// Hộp thoại chỉnh sửa danh sách

  void _showEditListDialog(Map<String, dynamic> list) {
    String updatedName = list['name'];
    String updatedDescription = list['description'] ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Chỉnh sửa danh sách"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: "Tên danh sách",
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: updatedName),
                onChanged: (value) {
                  updatedName = value;
                },
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  labelText: "Mô tả (không bắt buộc)",
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: updatedDescription),
                onChanged: (value) {
                  updatedDescription = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Đóng hộp thoại
              },
              child: Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (updatedName.isNotEmpty) {
                  await _updateList(
                      list['_id'], updatedName, updatedDescription);
                  Navigator.pop(context); // Đóng hộp thoại
                  setState(() {
                    _lists = _apiListService
                        .getAllLists(widget.boardId); // Làm mới danh sách
                  });
                }
              },
              child: Text("Lưu"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateList(String id, String name, String description) async {
    try {
      final updatedData = {
        'name': name,
        'description': description,
      };

      final response = await _apiListService.updateList(id, updatedData);

      // Kiểm tra phản hồi từ server
      if (response != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cập nhật danh sách thành công!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cập nhật danh sách thất bại!')),
        );
      }
    } catch (e) {
      // Xử lý lỗi nếu gặp phải
      print('Error updating list: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Có lỗi xảy ra khi cập nhật danh sách!')),
      );
    }
  }

  void _showDeleteConfirmationDialog(String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Xác nhận xóa"),
          content: Text("Bạn có chắc chắn muốn xóa danh sách này không?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Đóng hộp thoại
              },
              child: Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // Đóng hộp thoại
                bool success = await _apiListService.deleteList(id);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Xóa thành công!")),
                  );
                  setState(() {
                    _lists = _apiListService
                        .getAllLists(widget.boardId); // Làm mới danh sách
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Xóa thất bại!")),
                  );
                }
              },
              child: Text("Xóa"),
            ),
          ],
        );
      },
    );
  }
}
