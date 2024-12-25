class Board {
  String id; // ID của Board
  String name; // Tên Board
  String? description; // Mô tả (có thể null)
  bool status; // Trạng thái (true/false)
  DateTime createdAt; // Ngày tạo
  DateTime updatedAt; // Ngày cập nhật
  String owner; // ID của người tạo Board
  List<String> members; // Danh sách thành viên
  List<String> lists; // Danh sách các list trong Board

  Board({
    required this.id,
    required this.name,
    this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.owner,
    required this.members,
    required this.lists,
  });

  // Tạo Board từ JSON
  factory Board.fromJson(Map<String, dynamic> json) {
    return Board(
      id: json['_id'], // MongoDB sử dụng _id cho ID
      name: json['name'],
      description: json['description'],
      status: json['status'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      owner: json['owner'],
      members: List<String>.from(json['members'] ?? []),
      lists: List<String>.from(json['lists'] ?? []),
    );
  }

  // Chuyển Board sang JSON (dùng khi gửi dữ liệu lên server)
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'owner': owner,
      'members': members,
      'lists': lists,
    };
  }
}
