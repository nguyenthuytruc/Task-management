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

  // Thêm ghi chú mới
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
                  id: '',
                  name: noteName,
                  description: noteDescription,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  createdBy: idUser,
                  boardId: widget.boardId,
                  isPinned: false, // Ghi chú mặc định không được ghim
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

  // Xóa ghi chú
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

void _pinUnpinNote(Note note) async {
  // Đảo ngược trạng thái ghim
  Note updatedNote = Note(
    id: note.id,
    name: note.name,
    description: note.description,
    type: note.type,
    isPinned: !note.isPinned, // Đảo ngược trạng thái ghim
    createdAt: note.createdAt,
    updatedAt: DateTime.now(),
    createdBy: note.createdBy,
    boardId: note.boardId,
  );

  try {
    bool isUpdated = await _apiNoteService.updateNote(updatedNote);
    if (isUpdated) {
      
      setState(() {
        // Làm mới danh sách và sắp xếp lại các ghi chú
        _notes = _apiNoteService.getNotesByBoardId(widget.boardId);
      });
    } 
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Lỗi: ${e.toString()}')),
    );
  }
}

  // Chỉnh sửa ghi chú
  void _editNote(Note note) async {
    TextEditingController nameController = TextEditingController(text: note.name);
    TextEditingController descriptionController = TextEditingController(text: note.description);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Chỉnh Sửa Ghi Chú"),
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

                // Tạo đối tượng Note mới với dữ liệu đã chỉnh sửa
                Note updatedNote = Note(
                  id: note.id, // Giữ nguyên id cũ để cập nhật
                  name: noteName,
                  description: noteDescription,
                  type: note.type,
                  isPinned: !note.isPinned,
                  createdAt: note.createdAt,
                  updatedAt: DateTime.now(), // Cập nhật thời gian sửa đổi
                  createdBy: note.createdBy,
                  boardId: note.boardId,
                );

                try {
                  // Cập nhật ghi chú trên server
                  bool isUpdated = await _apiNoteService.updateNote(updatedNote);
                  if (isUpdated) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Đã cập nhật ghi chú thành công.'),
                      backgroundColor: Colors.blueAccent,
                    ));
                    Navigator.pop(context);
                    setState(() {
                      _notes = _apiNoteService.getNotesByBoardId(widget.boardId);
                    });
                  } else {
                    throw Exception('Cập nhật ghi chú thất bại');
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi: ${e.toString()}')),
                  );
                }
              },
              child: Text("Lưu Thay Đổi"),
            ),
          ],
        );
      },
    );
  }
//giao diện
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: _addNote, // Nút add note
            icon: Icon(Icons.add),
          ),
        ],
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
            // Sắp xếp ghi chú sao cho ghi chú đã ghim sẽ xuất hiện ở trên cùng
          notes.sort((a, b) {
            if (a.isPinned == b.isPinned) {
              return 0;
            }
            return a.isPinned ? -1 : 1;
          });
            return ListView.builder(
  itemCount: notes.length,
  itemBuilder: (context, index) {
    var note = notes[index];
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        title: Text(
          note.name,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          note.description ?? 'Không có mô tả',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              _editNote(note); // Hàm chỉnh sửa ghi chú
            } else if (value == 'delete') {
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
                          _deleteNote(note.id!); // Hàm xóa ghi chú
                        },
                        child: Text("Xóa"),
                      ),
                    ],
                  );
                },
              );
              
            } else if (value == 'pin') {
                          _pinUnpinNote(note); // Ghim hoặc bỏ ghim ghi chú
                        }
          },
          itemBuilder: (BuildContext context) => [
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
  value: 'pin',
  child: Row(
    children: [
      Icon(
        note.isPinned 
            ? Icons.push_pin // Sử dụng icon pin đẹp hơn
            : Icons.pin_drop, // Icon này cho trạng thái chưa ghim
        color: note.isPinned ? Colors.amber : Colors.grey, // Màu vàng cho ghim, màu xám cho không ghim
        size: 24, // Kích thước icon
      ),
      SizedBox(width: 8),
      Text(
        note.isPinned ? 'Bỏ ghim' : 'Ghim',
        style: TextStyle(
          fontSize: 16,
          color: note.isPinned ? Colors.amber : Colors.black, // Màu chữ
        ),
      ),
    ],
  ),
)

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
