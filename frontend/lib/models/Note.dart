class Note {
   String id;
   String name;
   String description;
   String createdBy;
   String board;
  bool isPinned; // Không phải final để có thể thay đổi trạng thái
   DateTime createdAt;
   DateTime updatedAt;

  Note({
    required this.id,
    required this.name,
    required this.description,
    required this.createdBy,
    required this.board,
    required this.isPinned,
    required this.createdAt,
    required this.updatedAt,
  });

  // Chuyển đổi từ JSON
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      createdBy: json['createdBy'],
      board: json['board'],
      isPinned: json['isPinned'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // Chuyển đổi sang JSON để gửi đi
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'createdBy': createdBy,
      'board': board,
      'isPinned': isPinned,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
