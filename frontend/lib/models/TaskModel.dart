import 'dart:convert';

// Mô hình Task cho Frontend
class TaskModel {
  String id; // ID của Task
  String name; // Tên Task
  String? description; // Mô tả của Task
  String status; // Trạng thái Task: "Pending", "In Progress", "Completed"
  DateTime createdAt; // Ngày tạo
  DateTime updatedAt; // Ngày cập nhật
  String createdBy; // ID người tạo Task
  String listId; // ID của List chứa Task
  List<String> permittedEmails; // Danh sách emails được phép

  // Constructor
  TaskModel({
    required this.id,
    required this.name,
    this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.listId,
    required this.permittedEmails,
  });

  // Tạo TaskModel từ JSON
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      status: json['status'],
      createdAt: DateTime.parse(json['createAt']),
      updatedAt: DateTime.parse(json['updateAt']),
      createdBy: json['createdBy'],
      listId: json['listId'],
      permittedEmails: List<String>.from(json['permitted'].map((email) => email['email'])),
    );
  }

  // Chuyển TaskModel sang JSON (dùng khi gửi dữ liệu lên server)
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'status': status,
      'createAt': createdAt.toIso8601String(),
      'updateAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'listId': listId,
      'permitted': permittedEmails.map((email) => {'email': email}).toList(),
    };
  }
}
