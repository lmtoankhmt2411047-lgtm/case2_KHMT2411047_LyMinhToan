import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../models/task_activity.dart';
import '../../services/task_service.dart';
import 'task_edit_screen.dart';
import 'task_share_screen.dart';

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
          Navigator.pop(context, true);
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

  // Thu hồi quyền truy cập của người dùng (C3)
  Future<void> _handleRemoveShare(String userId) async {
    try {
      final success = await TaskService.removeShareAccess(widget.taskId, userId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã thu hồi quyền truy cập')),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi thu hồi quyền: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi Tiết Công Việc'),
        actions: [
          FutureBuilder<Task>(
            future: _taskFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.share, color: Colors.green),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TaskShareScreen(task: snapshot.data!),
                    ),
                  );
                  if (result == true) {
                    _loadData();
                  }
                },
                tooltip: 'Giao việc & Chia sẻ',
              );
            },
          ),
          FutureBuilder<Task>(
            future: _taskFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TaskEditScreen(task: snapshot.data!),
                    ),
                  );
                  if (result == true) {
                    _loadData();
                  }
                },
                tooltip: 'Chỉnh sửa công việc',
              );
            },
          ),
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
                const Divider(height: 24),

                Text(
                  'Người Đang Phụ Trách',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (task.assignees.isEmpty)
                  const Text('Chưa giao cho ai', style: TextStyle(color: Colors.grey))
                else
                  Wrap(
                    spacing: 8,
                    children: task.assignees.map((assignee) {
                      return Chip(
                        avatar: Icon(
                          assignee.isPrimary ? Icons.star : Icons.person,
                          size: 18,
                          color: assignee.isPrimary ? Colors.amber : Colors.blue,
                        ),
                        label: Text(
                          '${assignee.fullName.isEmpty ? assignee.email : assignee.fullName}'
                              '${assignee.isPrimary ? ' (Chính)' : ''}',
                        ),
                      );
                    }).toList(),
                  ),
                const Divider(height: 24),

                Text(
                  'Người Được Chia Sẻ',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (task.sharedWith.isEmpty)
                  const Text('Chưa chia sẻ cho ai', style: TextStyle(color: Colors.grey))
                else
                  Wrap(
                    spacing: 8,
                    children: task.sharedWith.map((share) {
                      return Chip(
                        avatar: Icon(
                          share.role == 'editor' ? Icons.edit : Icons.remove_red_eye,
                          size: 18,
                        ),
                        label: Text(
                          '${share.fullName.isEmpty ? share.email : share.fullName} (${share.role})',
                        ),
                        onDeleted: () => _handleRemoveShare(share.userId),
                        deleteIcon: const Icon(Icons.cancel, size: 18, color: Colors.red),
                      );
                    }).toList(),
                  ),
                const Divider(height: 24),

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