import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class TaskListScreen extends StatelessWidget {
  final String token;
  const TaskListScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách công việc'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: ApiService.getTasks(token),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Chưa có công việc nào trong MongoDB'));
          }
          final tasks = snapshot.data!;
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(task['title'] ?? ''),
                  subtitle: Text('Ưu tiên: ${task['priority']} | Trạng thái: ${task['status']}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}