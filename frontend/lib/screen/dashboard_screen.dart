import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:frontend/models/api_userService.dart';
import 'package:frontend/screen/board_screen.dart';
import 'package:frontend/screen/coopBoard_screen.dart';
import 'package:frontend/screen/login_screen.dart';
import 'package:frontend/screen/note_screen.dart';
import 'package:frontend/screen/notification_screen.dart';
import 'package:frontend/screen/user_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  int _notificationCount = 0; // Số lượng thông báo
  final userService = UserService(); // Gọi service

  // Danh sách các màn hình
  final List<Widget> _widgetOptions = <Widget>[
    BoardScreen(),
    CoopBoardScreen(),
    BadgeScreen(),
    UserScreen(),
  ];

  // Đăng xuất
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  // Cập nhật chỉ số khi chọn mục mới
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Lấy số lượng thông báo từ API
  Future<void> _loadNotifications() async {
    try {
      final notiList =
          await userService.getNoti(); // Gọi API lấy danh sách thông báo
      setState(() {
        _notificationCount = notiList.length; // Cập nhật số lượng thông báo
      });
    } catch (e) {
      print("Lỗi khi lấy thông báo: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _loadNotifications(); // Tải thông báo khi vào màn hình chính
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Bảng',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.ac_unit),
            label: '...',
          ),
          BottomNavigationBarItem(
            icon: badges.Badge(
              badgeContent: Text(
                _notificationCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
              showBadge:
                  _notificationCount > 0, // Chỉ hiển thị nếu có thông báo
              position: badges.BadgePosition.topEnd(top: -10, end: -10),
              child: const Icon(Icons.notifications),
            ),
            label: 'Thông báo',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Tài khoản',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue[800], // Màu mục được chọn
        unselectedItemColor: Colors.grey, // Màu mục chưa chọn
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Giữ cố định kích thước các mục
      ),
    );
  }
}
