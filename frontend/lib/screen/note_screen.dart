import 'package:flutter/material.dart';
import 'package:frontend/models/api_noteService.dart';
import 'package:frontend/models/Note.dart';
import 'package:frontend/screen/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoteScreen extends StatefulWidget {
  final String boardId;

  NoteScreen({required this.boardId});

  @override
  _NoteScreenState createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  final ApiNoteService _apiNoteService = ApiNoteService();
  late Future<List<Note>> _notes;
  late String _idUser;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  // Hàm này kiểm tra và lấy idUser từ SharedPreferences
  Future<void> _loadUserId() async {
    final String? idUser = await getUserId();
    if (idUser != null && idUser.isNotEmpty) {
      setState(() {
        _idUser = idUser;
        _notes = _apiNoteService.getNotesByBoardId(widget.boardId);
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

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('idUser');
  }

  void _addNote() async {
    TextEditingController nameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Tạo Ghi Chú Mới"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Tên ghi chú"),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: "Mô tả"),
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
                String noteName = nameController.text;
                String noteDescription = descriptionController.text;

                if (noteName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Tên ghi chú không thể trống."),
                      backgroundColor: Colors.blueAccent,
                    ),
                  );
                  return;
                }

                final String? idUser = await getUserId();
                if (idUser == null || idUser.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Không tìm thấy id người dùng.'),
                      backgroundColor: Colors.blueAccent,
                    ),
                  );
                  return;
                }

                // Tạo đối tượng Note
                Note newNote = Note(
                  id: '', // id có thể để trống nếu server tự sinh
                  name: noteName,
                  description: noteDescription,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  createdBy: idUser, // idUser cần phải chắc chắn không phải null
                  boardId: widget.boardId,
                );

                try {
                  // Sử dụng phương thức toJson() để gửi dữ liệu đến API
                  bool isCreated = await _apiNoteService.createNote(newNote.toJson());
                  if (isCreated) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Đã tạo ghi chú mới thành công.'),
                      backgroundColor: Colors.blueAccent,
                    ));
                    Navigator.pop(context);
                    setState(() {
                      _notes = _apiNoteService.getNotesByBoardId(widget.boardId);
                    });
                  } else {
                    throw Exception('Tạo ghi chú thất bại');
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi: ${e.toString()}')),
                  );
                }
              },
              child: Text("Tạo Ghi Chú"),
            ),
          ],
        );
      },
    );
  }

  void _deleteNote(String noteId) async {
    try {
      bool isDeleted = await _apiNoteService.deleteNoteById(noteId);

      if (isDeleted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xóa ghi chú thành công.'),
            backgroundColor: Colors.blueAccent,
          ),
        );
        setState(() {
          _notes = _apiNoteService.getNotesByBoardId(widget.boardId);
        });
      } else {
        throw Exception('Xóa ghi chú thất bại.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xóa ghi chú: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.center,
          child: Text(
            "Danh Sách Ghi Chú",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<Note>>(
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
                return ListTile(
                  title: Text(note.name),
                  subtitle: Text(note.description ?? 'Không có mô tả'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Xác nhận xóa"),
                            content: Text("Bạn có chắc chắn muốn xóa ghi chú này không?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("Hủy"),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _deleteNote(note.id);
                                },
                                child: Text("Xóa"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        child: const Icon(Icons.add),
      ),
    );
  }
}
