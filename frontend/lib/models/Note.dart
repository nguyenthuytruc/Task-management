class Note {
  String? id; // id là nullable
  String name;
  String? description;
  String type;
  bool isPinned;
  DateTime createdAt;
  DateTime updatedAt;
  String createdBy;
  String boardId;

  Note({
    this.id, // id có thể nullable
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
      id: json['_id'] ?? '', // Đảm bảo id không null
      name: json['name'] ?? '', // Đảm bảo name không null
      description: json['description'] ?? '', // Đảm bảo description không null
      type: json['type'] ?? "Normal", // Giá trị mặc định nếu type null
      isPinned: json['isPinned'] ?? false, // Giá trị mặc định nếu isPinned null
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()), // Giá trị mặc định nếu createdAt null
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toString()), // Giá trị mặc định nếu updatedAt null
      createdBy: json['createdBy'] ?? '', // Đảm bảo createdBy không null
      boardId: json['boardId'] ?? '', // Đảm bảo boardId không null
    );
  }

  // Phương thức để chuyển một Note thành JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id ?? '', // Tránh giá trị null cho id
      'name': name.isEmpty ? '' : name, // Tránh giá trị null cho name
      'description': description ?? '', // Nếu description null, trả về chuỗi rỗng
      'type': type ?? 'Normal', // Nếu type null, trả về giá trị mặc định "Normal"
      'isPinned': isPinned,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy.isEmpty ? '' : createdBy, // Tránh giá trị null cho createdBy
      'boardId': boardId.isEmpty ? '' : boardId, // Tránh giá trị null cho boardId
    };
  }
}
