class Task {
  final String id;
  final String userId;
  String title;
  String description;
  bool isDone;
  DateTime createdAt;
  DateTime? dueDate;
  int priority;

  Task({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    this.isDone = false,
    DateTime? createdAt,
    this.dueDate,
    this.priority = 1,
  }) : createdAt = createdAt ?? DateTime.now();

  // Firestore serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'isDone': isDone,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      description: map['description'],
      isDone: map['isDone'],
      createdAt: DateTime.parse(map['createdAt']),
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      priority: map['priority'],
    );
  }
}
