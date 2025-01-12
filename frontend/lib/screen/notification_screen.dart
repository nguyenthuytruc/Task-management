import 'package:flutter/material.dart';
import 'package:frontend/models/api_userService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BadgeScreen extends StatefulWidget {
  @override
  _BadgeScreenState createState() => _BadgeScreenState();
}

class _BadgeScreenState extends State<BadgeScreen> {
  final userService = UserService(); // Gọi service
  Future<List<dynamic>>? _noti; // Danh sách thông báo
  String? _idUser; // ID người dùng

  // Lấy userId từ SharedPreferences
  Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('idUser');
  }

  // Load userId và danh sách thông báo
  Future<void> _loadUserId() async {
    final String? idUser = await _getUserId();
    if (idUser != null) {
      setState(() {
        _idUser = idUser;
        _noti = userService.getNoti(); // Gọi API lấy danh sách thông báo
      });
    }
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
        title: Text('Thông báo'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _noti,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator()); // Hiển thị khi đang tải
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Lỗi: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Không có thông báo nào.'));
          } else {
            final notifications = snapshot.data!;
            return ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final noti = notifications[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: Card(
                    elevation: 4, // Đổ bóng cho card
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Bo góc
                    ),
                    child: ListTile(
                      title: Text(
                        noti['title'] ?? 'No Title', // Tiêu đề thông báo
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text(
                        noti['description'] ??
                            'No Description', // Mô tả thông báo
                        style: TextStyle(fontSize: 14),
                      ),
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
