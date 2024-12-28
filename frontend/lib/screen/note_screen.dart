import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:frontend/models/Note.dart';
import 'package:frontend/models/api_noteService.dart';


class NoteScreen extends StatefulWidget {
  @override
  _NoteScreenState createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  final ApiNoteService apiNoteService = ApiNoteService();
  late Future<List<Note>> notes;

  @override
  void initState() {
    super.initState();
    notes = apiNoteService.getAllNotes();
  }

  // Hàm tạo ghi chú mới
  void _createNote() {
    final newNote = Note(
      id: '', // ID sẽ được backend tự sinh
      name: 'New Note',
      description: 'This is a new note description.',
      createdBy: 'User1',
      board: 'Board1',
      isPinned: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    apiNoteService.createNote(newNote).then((note) {
      setState(() {
        notes = apiNoteService.getAllNotes();
      });
    });
  }

  // Hàm thay đổi trạng thái ghim của ghi chú
  void _togglePinnedStatus(String noteId) {
    apiNoteService.updateStatus(noteId).then((success) {
      if (success) {
        setState(() {
          notes = apiNoteService.getAllNotes();
        });
      }
    });
  }

  // Hàm xóa ghi chú
  void _deleteNote(String noteId) {
    apiNoteService.deleteNote(noteId).then((success) {
      if (success) {
        setState(() {
          notes = apiNoteService.getAllNotes();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notes"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _createNote,
          ),
        ],
      ),
      body: FutureBuilder<List<Note>>(
        future: notes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No notes found.'));
          }

          final noteList = snapshot.data!;

          return ListView.builder(
            itemCount: noteList.length,
            itemBuilder: (context, index) {
              final note = noteList[index];
              return ListTile(
                title: Text(note.name),
                subtitle: Text(note.description),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                      ),
                      onPressed: () => _togglePinnedStatus(note.id),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteNote(note.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
