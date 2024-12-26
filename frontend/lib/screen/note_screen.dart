import 'package:flutter/material.dart';
import 'package:frontend/models/api_noteService.dart'; // Đảm bảo bạn đã import lớp ApiNoteService

class NoteScreen extends StatefulWidget {
  final String boardId; // ID của board được truyền vào

  const NoteScreen({Key? key, required this.boardId}) : super(key: key);

  @override
  _NoteScreenState createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  final ApiNoteService _apiNoteService = ApiNoteService();
  late Future<List<dynamic>> _notes;

  @override
  void initState() {
    super.initState();
    // Gọi API để lấy danh sách ghi chú của board
    _notes = _apiNoteService.getNotesByBoardId(widget.boardId);
  }

  // Hàm để thêm thành viên vào Board
  void _addMember() {
    TextEditingController memberController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Thêm Thành Viên'),
          content: TextField(
            controller: memberController,
            decoration: InputDecoration(hintText: 'Nhập email hoặc ID thành viên'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Giả lập thêm thành viên
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Thành viên đã được thêm')),
                );
              },
              child: Text('Thêm'),
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

  // Hàm xử lý chọn menu
  void _onMenuSelected(String value) {
    if (value == 'notes') {
      // Hiển thị ghi chú (mặc định)
    } else if (value == 'members') {
      _addMember(); // Mở form thêm thành viên
    }
  }

  // Hàm để tạo ghi chú mới
  void _createNewNote() {
    TextEditingController nameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Tạo Ghi Chú Mới'),
          content: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(hintText: 'Nhập tên ghi chú'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(hintText: 'Nhập mô tả ghi chú'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Thực hiện gọi API để tạo ghi chú mới
                Map<String, dynamic> noteData = {
                  'name': nameController.text,
                  'description': descriptionController.text,
                  'boardId': widget.boardId,  // ID board truyền vào
                };

                try {
                  await _apiNoteService.createNote(noteData);
                  Navigator.pop(context);  // Đóng dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ghi chú mới đã được tạo')),
                  );
                  setState(() {
                    _notes = _apiNoteService.getNotesByBoardId(widget.boardId); // Cập nhật lại danh sách ghi chú
                  });
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi: $e')),
                  );
                }
              },
              child: Text('Tạo'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Danh sách Ghi Chú"),
        actions: [
          PopupMenuButton<String>(
            onSelected: _onMenuSelected,
            itemBuilder: (context) => [
              PopupMenuItem(value: 'notes', child: Text('Ghi Chú')),
              PopupMenuItem(value: 'members', child: Text('Thành Viên')),
            ],
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _notes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Không có ghi chú nào."));
          } else {
            var notes = snapshot.data!;
            return ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                var note = notes[index];
                return NoteCard(note: note);
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewNote, // Mở màn hình tạo ghi chú mới
        child: Icon(Icons.add),
      ),
    );
  }
}

class NoteCard extends StatelessWidget {
  final dynamic note;

  const NoteCard({Key? key, required this.note}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: ListTile(
        title: Text(
          note['name'],
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(note['description'] ?? "Không có mô tả."),
        trailing: Icon(
          note['isPinned'] ? Icons.push_pin : Icons.notes,
          color: note['isPinned'] ? Colors.orange : Colors.grey,
        ),
        onTap: () {
          // Chuyển sang màn hình chi tiết ghi chú nếu cần
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoteDetailScreen(noteId: note['_id']),
            ),
          );
        },
      ),
    );
  }
}

class NoteDetailScreen extends StatelessWidget {
  final String noteId;

  const NoteDetailScreen({Key? key, required this.noteId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chi Tiết Ghi Chú')),
      body: Center(
        child: Text('Chi tiết của ghi chú ID: $noteId'),
      ),
    );
  }
}
