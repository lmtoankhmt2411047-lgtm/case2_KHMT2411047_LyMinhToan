import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';

class TaskShareScreen extends StatefulWidget {
  final Task task;

  const TaskShareScreen({super.key, required this.task});

  @override
  State<TaskShareScreen> createState() => _TaskShareScreenState();
}

class _TaskShareScreenState extends State<TaskShareScreen> {
  final _assignEmailController = TextEditingController();
  final _shareEmailController = TextEditingController();

  bool _isPrimaryAssignee = false;
  String _selectedRole = 'viewer';
  bool _isLoading = false;

  @override
  void dispose() {
    _assignEmailController.dispose();
    _shareEmailController.dispose();
    super.dispose();
  }

  Future<void> _handleAssignTask() async {
    final email = _assignEmailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập Email thành viên')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final success = await TaskService.assignTask(
        taskId: widget.task.id,
        email: email,
        isPrimary: _isPrimaryAssignee,
      );

      if (success && mounted) {
        _assignEmailController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Giao công việc thành công')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleShareTask() async {
    final email = _shareEmailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập Email cần chia sẻ')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final success = await TaskService.shareTask(
        taskId: widget.task.id,
        email: email,
        role: _selectedRole,
      );

      if (success && mounted) {
        _shareEmailController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chia sẻ công việc thành công')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giao Việc & Chia Sẻ'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.task.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Giao Công Việc',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _assignEmailController,
                      decoration: const InputDecoration(
                        labelText: 'Email thành viên được giao',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_add),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Là người phụ trách chính'),
                      value: _isPrimaryAssignee,
                      onChanged: (val) {
                        setState(() => _isPrimaryAssignee = val ?? false);
                      },
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _handleAssignTask,
                        icon: const Icon(Icons.assignment_ind),
                        label: const Text('Giao Việc'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Chia Sẻ & Phân Quyền',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _shareEmailController,
                      decoration: const InputDecoration(
                        labelText: 'Email người nhận chia sẻ',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.share),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Quyền truy cập',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'viewer', child: Text('Chỉ xem (Viewer)')),
                        DropdownMenuItem(value: 'editor', child: Text('Được chỉnh sửa (Editor)')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedRole = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _handleShareTask,
                        icon: const Icon(Icons.send),
                        label: const Text('Chia Sẻ'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}