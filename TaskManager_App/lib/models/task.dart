class Task {
  final String id;
  final String title;
  final String description;
  final String priority;
  final String status;
  final DateTime? startDate;
  final DateTime? dueDate;
  final String? createdBy;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    this.startDate,
    this.dueDate,
    this.createdBy,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['_id'] != null ? json['_id'].toString() : '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      priority: json['priority'] ?? 'medium',
      status: json['status'] ?? 'todo',
      startDate: json['startDate'] != null ? DateTime.tryParse(json['startDate']) : null,
      dueDate: json['dueDate'] != null ? DateTime.tryParse(json['dueDate']) : null,
      createdBy: json['createdBy'] is Map
          ? json['createdBy']['fullName']
          : json['createdBy']?.toString(),
    );
  }
}
