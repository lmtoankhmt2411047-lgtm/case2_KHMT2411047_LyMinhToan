class TaskAssignee {
  final String id;
  final String fullName;
  final String email;
  final bool isPrimary; // Người phụ trách chính

  TaskAssignee({
    required this.id,
    required this.fullName,
    required this.email,
    this.isPrimary = false,
  });

  factory TaskAssignee.fromJson(Map<String, dynamic> json) {
    return TaskAssignee(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      fullName: json['fullName'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      isPrimary: json['isPrimary'] ?? false,
    );
  }
}

class TaskShare {
  final String userId;
  final String fullName;
  final String email;
  final String role; // 'viewer' hoặc 'editor'

  TaskShare({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.role,
  });

  factory TaskShare.fromJson(Map<String, dynamic> json) {
    final userObj = json['userId'] is Map ? json['userId'] : {};
    return TaskShare(
      userId: userObj['_id']?.toString() ?? json['userId']?.toString() ?? '',
      fullName: userObj['fullName'] ?? '',
      email: userObj['email'] ?? '',
      role: json['role'] ?? 'viewer',
    );
  }
}

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime? startDate;
  final DateTime? dueDate;
  final String priority;
  final String status;
  final String creatorId;
  final List<TaskAssignee> assignees;
  final List<TaskShare> sharedWith;

  Task({
    required this.id,
    required this.title,
    required this.description,
    this.startDate,
    this.dueDate,
    required this.priority,
    required this.status,
    required this.creatorId,
    this.assignees = const [],
    this.sharedWith = const [],
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['_id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      priority: json['priority'] ?? 'medium',
      status: json['status'] ?? 'todo',
      creatorId: json['creatorId'] is Map
          ? (json['creatorId']['_id']?.toString() ?? '')
          : (json['creatorId']?.toString() ?? ''),
      assignees: (json['assignees'] as List?)
          ?.map((item) => TaskAssignee.fromJson(item as Map<String, dynamic>))
          .toList() ??
          [],
      sharedWith: (json['sharedWith'] as List?)
          ?.map((item) => TaskShare.fromJson(item as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }
}