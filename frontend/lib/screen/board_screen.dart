import 'package:flutter/material.dart';
import 'package:frontend/models/api_boardService.dart';
import 'package:frontend/screen/list_screen.dart';
import 'package:frontend/screen/login_screen.dart';
import 'package:frontend/screen/note_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BoardScreen extends StatefulWidget {
  @override
  _BoardScreenState createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  final ApiBoardService _apiUserService = ApiBoardService();
  late Future<List<dynamic>> _boards;
  String? _idUser;

  Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('idUser');
  }

  Future<void> _loadUserId() async {
    final String? idUser = await _getUserId();
    if (idUser != null) {
      setState(() {
        _idUser = idUser;
        _boards = _apiUserService.getAllBoards(idUser);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không tìm thấy id người dùng.')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  void _updateBoard(
      String boardId, String currentName, String currentDescription) async {
    TextEditingController nameController =
        TextEditingController(text: currentName);
    TextEditingController descriptionController =
        TextEditingController(text: currentDescription);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Cập Nhật Board"),
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
            onPressed: () => Navigator.pop(context),
            child: Text("Hủy"),
          ),
          TextButton(
            onPressed: () async {
              String newName = nameController.text;
              String newDescription = descriptionController.text;

              if (newName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Tên board không thể trống."),
                    backgroundColor: Colors.blueAccent,
                  ),
                );
                return;
              }

              try {
                Map<String, dynamic> updatedData = {
                  'name': newName,
                  'description': newDescription,
                };
                bool isUpdated =
                    await _apiUserService.updateBoard(boardId, updatedData);

                if (isUpdated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã cập nhật board thành công.'),
                      backgroundColor: Colors.blueAccent,
                    ),
                  );
                  Navigator.pop(context);
                  setState(() {
                    _boards = _apiUserService.getAllBoards(_idUser ?? "");
                  });
                } else {
                  throw Exception('Cập nhật board thất bại.');
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi khi cập nhật board: $e')),
                );
              }
            },
            child: Text("Cập Nhật"),
          ),
        ],
      ),
    );
  }

  void _addMember(String boardId) async {
    // Controller để lấy thông tin thành viên
    TextEditingController memberController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Thêm Thành Viên"),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: memberController,
              decoration:
                  InputDecoration(labelText: "Email hoặc ID Thành Viên"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Hủy"),
          ),
          TextButton(
            onPressed: () async {
              String newMember = memberController.text;

              if (newMember.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Email hoặc ID thành viên không thể trống."),
                    backgroundColor: Colors.blueAccent,
                  ),
                );
                return;
              }

              try {
                // Gọi API để thêm thành viên vào board
                bool isAdded =
                    await _apiUserService.addMembers(boardId, newMember);

                if (isAdded) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã thêm thành viên thành công.'),
                      backgroundColor: Colors.blueAccent,
                    ),
                  );
                  Navigator.pop(context);
                  setState(() {
                    _boards = _apiUserService.getAllBoards(_idUser ?? "");
                  });
                } else {
                  throw Exception('Thêm thành viên thất bại.');
                }
              } catch (e) {
                print(e.toString().split(":")[2]);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(e.toString().split(":")[2] ??
                          'Đã xảy ra lỗi không xác định.')),
                );
              }
            },
            child: Text("Thêm Thành Viên"),
          ),
        ],
      ),
    );
  }

  void _addBoard() async {
    TextEditingController nameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
            onPressed: () => Navigator.pop(context),
            child: Text("Hủy"),
          ),
          TextButton(
            onPressed: () async {
              String boardName = nameController.text;
              String boardDescription = descriptionController.text;

              if (boardName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Tên board không thể trống."),
                    backgroundColor: Colors.blueAccent,
                  ),
                );
                return;
              }

              final String? idUser = await _getUserId();
              if (idUser == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Không tìm thấy id người dùng.'),
                    backgroundColor: Colors.blueAccent,
                  ),
                );
                return;
              }

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

                if (response.containsKey('data')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã tạo board mới thành công.'),
                      backgroundColor: Colors.blueAccent,
                    ),
                  );
                  Navigator.pop(context);
                  setState(() {
                    _boards = _apiUserService.getAllBoards(idUser);
                  });
                } else {
                  throw Exception('Tạo board thất bại');
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi: ${e.toString()}')),
                );
              }
            },
            child: Text("Tạo Board"),
          ),
        ],
      ),
    );
  }

  void _deleteBoard(String boardId) async {
    try {
      bool isDeleted = await _apiUserService.deleteBoard(boardId);

      if (isDeleted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xóa board thành công.'),
            backgroundColor: Colors.blueAccent,
          ),
        );
        setState(() {
          _boards = _apiUserService.getAllBoards(_idUser ?? "");
        });
      } else {
        throw Exception('Xóa board thất bại.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xóa board: $e')),
      );
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: _addBoard,
            icon: Icon(Icons.add),
          ),
        ],
        title: Center(
          child: Text(
            "QTV",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2.0,
            ),
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _boards,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Bạn không có board nào."));
          } else {
            var boards = snapshot.data!;
            return ListView.builder(
              itemCount: boards.length,
              itemBuilder: (context, index) {
                var board = boards[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: ListTile(
                    title: Text(
                      board['name'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(board['description']),
                    onTap: () {
                      // Ensure boardId is valid before navigation
                      if (board['_id'] != null && board['_id'].isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ListScreen(
                              board: board,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Board không hợp lệ.')),
                        );
                      }
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.note, color: Colors.blue),
                          onPressed: () {
                            if (board['_id'].isNotEmpty) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NoteScreen(
                                    boardId: board[
                                        '_id'], // Chuyển boardId qua NoteScreen
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Board không hợp lệ.')),
                              );
                            }
                          },
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _updateBoard(board['_id'], board['name'],
                                  board['description']);
                            } else if (value == 'delete') {
                              _deleteBoard(board['_id']);
                            } else if (value == 'addmember') {
                              _addMember(board['_id']);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text('Chỉnh sửa'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Xóa'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'addmember',
                              child: Row(
                                children: [
                                  Icon(Icons.people, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Thêm thành viên'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
