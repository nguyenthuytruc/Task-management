class ListModel {
  String id; // ID của List
  String name; // Tên List
  String? description; // Mô tả (có thể null)
  String? color; // Màu sắc (có thể null)
  DateTime createdAt; // Ngày tạo
  DateTime updatedAt; // Ngày cập nhật
  String createdBy; // ID của người tạo List
  String boardId; // ID của Board chứa List
  List<String> tasks; // Danh sách các task trong List

  // Constructor
  ListModel({
    required this.id,
    required this.name,
    this.description,
    this.color,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.boardId,
    required this.tasks,
  });

  // Tạo ListModel từ JSON
  factory ListModel.fromJson(Map<String, dynamic> json) {
    return ListModel(
      id: json['_id'], // MongoDB sử dụng _id cho ID
      name: json['name'],
      description: json['description'],
      color: json['color'],
      createdAt: DateTime.parse(json['createAt']),
      updatedAt: DateTime.parse(json['updateAt']),
      createdBy: json['createdBy'],
      boardId: json['boardId'],
      tasks: List<String>.from(json['tasks'] ?? []),
    );
  }

  // Chuyển ListModel sang JSON (dùng khi gửi dữ liệu lên server)
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'color': color,
      'createAt': createdAt.toIso8601String(),
      'updateAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'boardId': boardId,
      'tasks': tasks,
    };
  }
}
