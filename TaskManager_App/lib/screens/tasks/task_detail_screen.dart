import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../models/task_activity.dart';
import '../../services/task_service.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late Future<Task> _taskFuture;
  late Future<List<TaskActivity>> _activitiesFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _taskFuture = TaskService.getTaskById(widget.taskId);
      _activitiesFuture = TaskService.getTaskActivities(widget.taskId);
    });
  }

  // Xử lý Xóa công việc (B3)
  Future<void> _handleDeleteTask() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa công việc này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final success = await TaskService.deleteTask(widget.taskId);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Xóa công việc thành công')),
          );
          Navigator.pop(context, true); // Trả về true để danh sách tự làm mới
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi khi xóa: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi Tiết Công Việc'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _handleDeleteTask,
            tooltip: 'Xóa công việc',
          ),
        ],
      ),
      body: FutureBuilder<Task>(
        future: _taskFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          final task = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thông tin chính công việc
                Text(
                  task.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Mô tả: ${task.description.isEmpty ? 'Không có mô tả' : task.description}'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Chip(label: Text('Mức ưu tiên: ${task.priority.toUpperCase()}')),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text('Trạng thái: ${task.status}'),
                      backgroundColor: task.status == 'completed'
                          ? Colors.green.shade100
                          : Colors.orange.shade100,
                    ),
                  ],
                ),
                const Divider(height: 32),

                // Phần hiển thị Nhật ký hoạt động (B4 / E)
                Text(
                  'Lịch Sử Hoạt Động',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                FutureBuilder<List<TaskActivity>>(
                  future: _activitiesFuture,
                  builder: (context, actSnapshot) {
                    if (actSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (actSnapshot.hasError) {
                      return Text('Lỗi tải nhật ký: ${actSnapshot.error}');
                    }
                    final activities = actSnapshot.data ?? [];
                    if (activities.isEmpty) {
                      return const Text('Chưa có nhật ký hoạt động');
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: activities.length,
                      itemBuilder: (context, index) {
                        final activity = activities[index];
                        return ListTile(
                          leading: const Icon(Icons.history),
                          title: Text('${activity.userName}: ${activity.action}'),
                          subtitle: Text(activity.createdAt.toLocal().toString().split('.')[0]),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}