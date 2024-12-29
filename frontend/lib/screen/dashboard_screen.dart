// ignore_for_file: override_on_non_overriding_member, prefer_const_constructors, annotate_overrides

import 'package:flutter/material.dart';
import 'package:frontend/screen/board_screen.dart';
import 'package:frontend/screen/login_screen.dart';
import 'package:frontend/screen/note_screen.dart';
import 'package:frontend/screen/user_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  int _selectedIndex = 0;

  // Danh sách các màn hình
  final List<Widget> _widgetOptions = <Widget>[
    BoardScreen(),
    // NoteScreen(boardId: "0"),
    UserScreen(),
    //UserScreen(),
  ];
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Cập nhật index khi tab được chọn
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   actions: [
      //     IconButton(
      //       onPressed: logout, // Nút đăng xuất
      //       icon: Icon(Icons.logout), // Biểu tượng logout
      //     ),
      //   ],
      // ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Board',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.note),
          //   label: 'Note',
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'User',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
