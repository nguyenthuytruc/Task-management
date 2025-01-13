import 'package:flutter/material.dart';
import 'package:frontend/models/api_userService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class BadgeScreen extends StatefulWidget {
  @override
  _BadgeScreenState createState() => _BadgeScreenState();
}

class _BadgeScreenState extends State<BadgeScreen> {
  final userService = UserService();
  Future<List<dynamic>>? _noti;
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
        _noti = userService.getNoti();
      });
    }
  }

  Future<void> _markAsRead(int index) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? readNotiIds = prefs.getStringList('readNotiIds') ?? [];
    final notifications = await _noti;

    if (notifications != null &&
        !readNotiIds.contains(notifications[index]['id'])) {
      readNotiIds.add(notifications[index]['id'].toString());
      await prefs.setStringList('readNotiIds', readNotiIds);

      setState(() {
        notifications[index]['isRead'] = true;
      });
    }
  }

  Future<void> _deleteNotification(String id, int index) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> notifications = prefs.getStringList("notifications") ?? [];
    print(id);
    try {
      // Gọi API để xóa thông báo
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/users/noti/delete/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        _loadNotifications();
      } else {
        throw Exception('Failed to delete notification');
      }
    } catch (error) {
      // Hiển thị lỗi nếu không xóa được thông báo
      print('$error');
    }
  }

  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final apiNotifications =
          await userService.getNoti(); // Gọi API lấy danh sách thông báo
      if (apiNotifications != null) {
        setState(() {
          for (var notification in apiNotifications) {
            notification['isRead'] = false; // Gán mặc định là chưa đọc
          }
        });

        // Cập nhật SharedPreferences với danh sách thông báo từ API
        await prefs.setStringList('notifications',
            apiNotifications.map((n) => n.toString()).toList());
      }
    } catch (e) {
      print("Lỗi khi lấy thông báo từ API: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserId(); // Lấy idUser
    _loadNotifications(); // Tải thông báo và đồng bộ trạng thái đã đọc/xóa từ SharedPreferences
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
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Không có thông báo nào.'));
          } else {
            final notifications = snapshot.data!;
            return ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final noti = notifications[index];
                final isRead = noti['isRead'] ?? false;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        noti['title'] ?? 'No Title',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: isRead ? Colors.grey : Colors.black,
                        ),
                      ),
                      subtitle: Text(
                        noti['description'] ?? 'No Description',
                        style: TextStyle(fontSize: 14),
                      ),
                      trailing: PopupMenuButton(
                        onSelected: (value) {
                          if (value == 'read') {
                            _markAsRead(index);
                          } else if (value == 'delete') {
                            _deleteNotification(noti["_id"], index);
                          }
                        },
                        icon: Icon(
                          Icons.more_vert,
                          color: isRead ? Colors.green : Colors.grey,
                        ),
                        itemBuilder: (BuildContext context) => [
                          PopupMenuItem(
                            value: 'read',
                            child: Text('Đánh dấu đã đọc'),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text('Xóa'),
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
    );
  }
}
