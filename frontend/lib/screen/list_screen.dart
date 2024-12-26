import 'package:flutter/material.dart';
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
  late Future<List<dynamic>> _lists; // Future chứa danh sách các List của Board
  late String _userId; // Biến để lưu idUser
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Gọi API để lấy danh sách các List của Board khi màn hình được load
    _getUserId();
    _lists = _apiListService.getAllLists(widget.boardId); // Truyền boardId vào API
  }
    Future<void> _getUserId() async {
        final prefs = await SharedPreferences.getInstance();
        setState(() {
          _userId = prefs.getString('idUser') ?? ''; // Lấy idUser từ SharedPreferences
        });
      }
  @override
  Widget build(BuildContext context) {
    // In giá trị của boardId ra console
    print('Board ID: ${widget.boardId}');

    return Scaffold(
      appBar: AppBar(
        title: Text("Danh Sách Các List"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _showAddListDialog(); // Hiển thị biểu mẫu thêm
            },
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _lists, // Sử dụng Future để lấy danh sách List
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Khi dữ liệu đang được tải
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Khi có lỗi khi lấy dữ liệu
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Nếu không có danh sách nào
            return Center(child: Text("Không có danh sách nào."));
          } else {
            // Nếu dữ liệu đã được lấy thành công
            var lists = snapshot.data!;
            return ListView.builder(
              itemCount: lists.length,
              itemBuilder: (context, index) {
                var list = lists[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: ListTile(
                    title: Text(list['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(list['description'] ?? 'Không có mô tả'),
                    onTap: () {
                      // Xử lý khi nhấn vào một list (có thể thêm hành động ở đây nếu cần)
                    },
                  ),
                );
              },
            );
          }
        },
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
                  await _addNewList(newListName, newListDescription); // Gọi API để thêm
                  Navigator.pop(context); // Đóng hộp thoại
                  setState(() {
                    _lists = _apiListService.getAllLists(widget.boardId); // Làm mới danh sách
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

  // Thêm danh sách mới thông qua API
  // Phương thức tạo danh sách mới
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
    if (newList != null && newList['name'] != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tạo danh sách mới thành công: ${newList['name']}')),
      );
    } else {
      // Nếu không có dữ liệu hợp lệ từ API, hiển thị thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thêm danh sách thất bại: Không có dữ liệu trả về')),
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

}
