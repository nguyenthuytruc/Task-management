import 'package:flutter/material.dart';
import 'package:frontend/models/api_boardService.dart';
import 'package:frontend/screen/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/screen/list_screen.dart';

class BoardScreen extends StatefulWidget {
  @override
  _BoardScreenState createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  // @override
  final ApiUserService _apiUserService =
      ApiUserService(); // Tạo đối tượng ApiUserService
  late Future<List<dynamic>> _boards; // Future để chứa danh sách các board
  String? _idUser;

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('idUser'); // Lấy idUser đã lưu
  }

  Future<void> _loadUserId() async {
    final String? idUser = await getUserId();
    if (idUser != null) {
      _boards = _apiUserService.getAllBoards(idUser ?? "");
      setState(() {
        _idUser = idUser;
      });
      // Cập nhật lại UI sau khi dữ liệu được load
    } else {
      // Xử lý khi không có idUser (ví dụ như người dùng chưa đăng nhập)
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không tìm thấy id người dùng.')));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ),
      );
    }
  }

  void _addBoard() async {
    // Show a dialog to get the board name and description from the user
    TextEditingController nameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Tạo Board Mới"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Tên Board"),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: "Mô Tả"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Đóng dialog
              },
              child: Text("Hủy"),
            ),
            TextButton(
              onPressed: () async {
                String boardName = nameController.text;
                String boardDescription = descriptionController.text;

                if (boardName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Tên board không thể trống.")));
                  return;
                }

                // Lấy idUser từ SharedPreferences hoặc từ context
                final String? idUser = await getUserId();
                if (idUser == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Không tìm thấy id người dùng.')));
                  return;
                }

                // Tạo board mới bằng API
                Map<String, dynamic> boardData = {
                  'name': boardName,
                  'description': boardDescription,
                  'status': false,
                  'owner': idUser,
                  'members': [idUser],
                  'lists': [],
                };

                try {
                  var response = await _apiUserService.createBoard(boardData);

                  // Xử lý khi tạo board thành công
                  if (response.containsKey('data')) {
                    var newBoard = response['data'];
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Đã tạo board mới thành công.')));
                    Navigator.pop(context); // Đóng dialog
                    // Thực hiện load lại danh sách boards hoặc chuyển hướng đến board mới
                    setState(() {
                      _boards = _apiUserService.getAllBoards(idUser);
                    });
                  } else {
                    throw Exception('Tạo board thất bại');
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi: ${e.toString()}')));
                }
              },
              child: Text("Tạo Board"),
            ),
          ],
        );
      },
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Lấy idUser từ login response (được truyền từ LoginScreen)
    final String? idUser =
        ModalRoute.of(context)?.settings.arguments.toString();
    if (idUser == 'null') {
      // Nếu idUser null hoặc rỗng, gọi hàm _loadUserId() để xử lý
      _loadUserId();
      _boards = _loadUserIdAndGetBoards();
    } else {
      _idUser = idUser;
      // Gọi API lấy danh sách boards của người dùng khi màn hình được load
      _boards = _apiUserService.getAllBoards(idUser ?? "");
    }
  }

  Future<List<dynamic>> _loadUserIdAndGetBoards() async {
    // Giả sử bạn có hàm để lấy idUser
    if (_idUser != null) {
      return _apiUserService.getAllBoards(_idUser ?? "");
    } else {
      _loadUserId();
      return []; // Trả về danh sách rỗng nếu không có idUser
    }
  }

//cái này thêm rồi
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: logout, // Nút đăng xuất
            icon: Icon(Icons.logout), // Biểu tượng logout
          ),
        ],
        title: Text("Các Board Của Bạn"),
        backgroundColor: Colors.blue, // Tiêu đề màn hình
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _boards, // Sử dụng Future để lấy boards
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Khi dữ liệu đang được tải
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Khi có lỗi khi lấy dữ liệu
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Nếu không có board nào
            return Center(child: Text("Bạn không có board nào."));
          } else {
            // Nếu dữ liệu đã được lấy thành công
            var boards = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                children: boards.map((board) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: ListTile(
                      title: Text(
                        board['name'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(board['description']),
                      trailing: Icon(
                        board['status'] ? Icons.check_circle : Icons.cancel,
                        color: board['status'] ? Colors.green : Colors.red,
                      ),
                      onTap: () {
                        print('Navigating to ListScreen with boardId: ${board['_id']}');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ListScreen(boardId: board['_id']),
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addBoard,
        child: const Icon(Icons.add),
      ),
    );
  }
}
