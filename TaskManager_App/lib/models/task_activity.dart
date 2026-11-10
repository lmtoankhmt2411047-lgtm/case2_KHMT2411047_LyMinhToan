class TaskActivity {
  final String id;
  final String taskId;
  final String userName;
  final String action;
  final DateTime createdAt;

  TaskActivity({
    required this.id,
    required this.taskId,
    required this.userName,
    required this.action,
    required this.createdAt,
  });

  factory TaskActivity.fromJson(Map<String, dynamic> json) {
    return TaskActivity(
      id: json['_id']?.toString() ?? '',
      taskId: json['taskId']?.toString() ?? '',
      userName: json['userId'] is Map
          ? (json['userId']['fullName'] ?? 'Người dùng')
          : 'Người dùng',
      action: json['action'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}