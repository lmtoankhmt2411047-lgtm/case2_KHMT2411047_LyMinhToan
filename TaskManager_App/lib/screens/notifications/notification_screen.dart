import 'package:flutter/material.dart';
import '../../models/notification_model.dart';
import '../../services/notification_service.dart';
import '../tasks/task_detail_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  final Color _primaryColor = const Color(0xFF6A5AE0);

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() => _isLoading = true);
    try {
      final list = await NotificationService.getNotifications();
      if (mounted) {
        setState(() => _notifications = list);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông Báo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: _primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _primaryColor))
          : _notifications.isEmpty
          ? const Center(child: Text('Chưa có thông báo nào'))
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final item = _notifications[index];
          return Card(
            color: item.isRead ? Colors.white : Colors.indigo.shade50,
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _primaryColor.withOpacity(0.1),
                child: Icon(Icons.notifications, color: _primaryColor),
              ),
              title: Text(
                item.title,
                style: TextStyle(
                  fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(item.message),
                  const SizedBox(height: 4),
                  Text(
                    '${item.createdAt.hour}:${item.createdAt.minute} - ${item.createdAt.day}/${item.createdAt.month}/${item.createdAt.year}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
              onTap: () async {
                if (!item.isRead) {
                  await NotificationService.markAsRead(item.id);
                  _fetchNotifications();
                }
                if (item.taskId != null && mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TaskDetailScreen(taskId: item.taskId!),
                    ),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}