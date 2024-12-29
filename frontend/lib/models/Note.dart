class Note {
  final String id;
  final String name;
  final String description;
  final String createdBy;
  final String board;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;

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
}
