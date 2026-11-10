import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';
import 'task_create_screen.dart';
import 'task_detail_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  late Future<List<Task>> _taskListFuture;
  List<Task> _allTasks = [];
  List<Task> _filteredTasks = [];

  String _searchQuery = '';
  String _selectedStatus = 'all';
  String _selectedPriority = 'all';

  @override
  void initState() {
    super.initState();
    _refreshTasks();
  }

  void _refreshTasks() {
    setState(() {
      _taskListFuture = TaskService.getTasks().then((tasks) {
        _allTasks = tasks;
        _applyFilter();
        return tasks;
      });
    });
  }

  void _applyFilter() {
    setState(() {
      _filteredTasks = _allTasks.where((task) {
        // Lọc theo từ khóa tìm kiếm
        final matchesSearch = task.title.toLowerCase().contains(_searchQuery.toLowerCase());

        // Lọc theo trạng thái
        final matchesStatus = _selectedStatus == 'all' || task.status == _selectedStatus;

        // Lọc theo mức ưu tiên
        final matchesPriority = _selectedPriority == 'all' || task.priority == _selectedPriority;

        return matchesSearch && matchesStatus && matchesPriority;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh Sách Công Việc'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshTasks,
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Thanh tìm kiếm & bộ lọc
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Tìm kiếm theo tên công việc...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (val) {
                    _searchQuery = val;
                    _applyFilter();
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Trạng thái',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('Tất cả')),
                          DropdownMenuItem(value: 'todo', child: Text('Chưa làm')),
                          DropdownMenuItem(value: 'in_progress', child: Text('Đang làm')),
                          DropdownMenuItem(value: 'completed', child: Text('Đã xong')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            _selectedStatus = val;
                            _applyFilter();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedPriority,
                        decoration: const InputDecoration(
                          labelText: 'Ưu tiên',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('Tất cả')),
                          DropdownMenuItem(value: 'low', child: Text('Thấp')),
                          DropdownMenuItem(value: 'medium', child: Text('Trung bình')),
                          DropdownMenuItem(value: 'high', child: Text('Cao')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            _selectedPriority = val;
                            _applyFilter();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. Danh sách công việc sau khi lọc
          Expanded(
            child: FutureBuilder<List<Task>>(
              future: _taskListFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                }
                if (_filteredTasks.isEmpty) {
                  return const Center(child: Text('Không tìm thấy công việc nào'));
                }

                return ListView.builder(
                  itemCount: _filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = _filteredTasks[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Ưu tiên: ${task.priority.toUpperCase()} | Trạng thái: ${task.status}'),
                        trailing: Icon(
                          task.status == 'completed' ? Icons.check_circle : Icons.pending_actions,
                          color: task.status == 'completed' ? Colors.green : Colors.orange,
                        ),
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TaskDetailScreen(taskId: task.id),
                            ),
                          );
                          if (result == true) {
                            _refreshTasks();
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TaskCreateScreen()),
          );
          if (result == true) {
            _refreshTasks();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}