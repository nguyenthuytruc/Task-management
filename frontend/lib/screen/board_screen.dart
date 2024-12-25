import 'package:flutter/material.dart';
import 'package:frontend/models/api_boardService.dart';

class BoardScreen extends StatefulWidget {
  @override
  _BoardScreenState createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  final ApiUserService _apiUserService =
      ApiUserService(); // Tạo đối tượng ApiUserService
  late Future<List<dynamic>> _boards; // Future để chứa danh sách các board

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Lấy idUser từ login response (được truyền từ LoginScreen)
    final String idUser = ModalRoute.of(context)?.settings.arguments as String;

    // Gọi API lấy danh sách boards của người dùng khi màn hình được load
    _boards = _apiUserService.getAllBoards(idUser);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Các Board Của Bạn")), // Tiêu đề màn hình
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
            return ListView.builder(
              itemCount: boards.length,
              itemBuilder: (context, index) {
                var board = boards[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: ListTile(
                    title: Text(board['name'],
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(board['description']),
                    trailing: Icon(
                      board['status'] ? Icons.check_circle : Icons.cancel,
                      color: board['status'] ? Colors.green : Colors.red,
                    ),
                    onTap: () {
                      // Xử lý khi nhấn vào một board, có thể thêm hành động ở đây nếu cần
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
}
