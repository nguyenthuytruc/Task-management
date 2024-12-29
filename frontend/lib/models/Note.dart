class Note {
  String id; // Đổi id thành nullable
  String name;
  String? description;
  String type;
  bool isPinned;
  DateTime createdAt;
  DateTime updatedAt;
  String createdBy;
  String boardId;

  Note({
    required this.id, // id là tham số tùy chọn
    required this.name,
    this.description,
    this.type = "Normal",
    this.isPinned = false,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.boardId,
  });

  // Phương thức factory để tạo một Note từ JSON
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      type: json['type'] ?? "Normal",
      isPinned: json['isPinned'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      createdBy: json['createdBy'],
      boardId: json['boardId'],
    );
  }

  // Phương thức để chuyển một Note thành JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'type': type,
      'isPinned': isPinned,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'boardId': boardId,
    };
  }
}
