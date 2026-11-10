import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';
import '../login_screen.dart';
import 'task_create_screen.dart';
import 'task_detail_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> _allTasks = [];
  List<Task> _filteredTasks = [];
  bool _isLoading = true;
  String _errorMessage = '';

  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedStatus = 'All';
  String _selectedPriority = 'All';

  final Color _primaryColor = const Color(0xFF6A5AE0);

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // Hàm xử lý Đăng xuất
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('token');
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  Future<void> _fetchTasks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final tasks = await TaskService.getTasks();
      setState(() {
        _allTasks = tasks;
        _applyFilter();
      });
    } catch (e) {
      final errorMsg = e.toString();
      // Nếu lỗi do Token không hợp lệ hoặc hết hạn -> Tự động gợi ý Đăng xuất
      if (errorMsg.contains('Token') || errorMsg.contains('chưa đăng nhập')) {
        setState(() {
          _errorMessage = 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại!';
        });
      } else {
        setState(() {
          _errorMessage = 'Không thể kết nối hoặc đường dẫn API chưa đúng.\nChi tiết: $e';
        });
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilter() {
    final query = _searchCtrl.text.toLowerCase().trim();
    setState(() {
      _filteredTasks = _allTasks.where((task) {
        final matchesSearch = task.title.toLowerCase().contains(query) ||
            task.description.toLowerCase().contains(query);

        final matchesStatus = _selectedStatus == 'All' ||
            task.status.toLowerCase() == _selectedStatus.toLowerCase();

        final matchesPriority = _selectedPriority == 'All' ||
            task.priority.toLowerCase() == _selectedPriority.toLowerCase();

        return matchesSearch && matchesStatus && matchesPriority;
      }).toList();
    });
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
      case 'cao':
        return Colors.red.shade400;
      case 'medium':
      case 'trung bình':
        return Colors.orange.shade400;
      default:
        return Colors.green.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _primaryColor,
        title: const Text(
          'Danh Sách Công Việc',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchTasks,
            tooltip: 'Tải lại',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => _applyFilter(),
                  style: const TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm theo tên công việc...',
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF6A5AE0)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          // Đã sửa withOpacity sang withValues theo chuẩn Flutter mới
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedStatus,
                            dropdownColor: _primaryColor,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                            items: const [
                              DropdownMenuItem(value: 'All', child: Text('Trạng thái: Tất cả')),
                              DropdownMenuItem(value: 'pending', child: Text('Chưa làm')),
                              DropdownMenuItem(value: 'in_progress', child: Text('Đang làm')),
                              DropdownMenuItem(value: 'completed', child: Text('Hoàn thành')),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                _selectedStatus = val;
                                _applyFilter();
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          // Đã sửa withOpacity sang withValues theo chuẩn Flutter mới
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedPriority,
                            dropdownColor: _primaryColor,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                            items: const [
                              DropdownMenuItem(value: 'All', child: Text('Ưu tiên: Tất cả')),
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
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: _primaryColor))
                : _errorMessage.isNotEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black87),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: _primaryColor),
                      onPressed: _errorMessage.contains('đăng nhập') ? _logout : _fetchTasks,
                      child: Text(
                        _errorMessage.contains('đăng nhập') ? 'Đăng nhập lại' : 'Thử lại',
                        style: const TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
            )
                : _filteredTasks.isEmpty
                ? const Center(child: Text('Không tìm thấy công việc nào'))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredTasks.length,
              itemBuilder: (context, index) {
                final task = _filteredTasks[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(
                      task.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          task.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                // Đã sửa withOpacity sang withValues theo chuẩn Flutter mới
                                color: _getPriorityColor(task.priority).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Ưu tiên: ${task.priority}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _getPriorityColor(task.priority),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                task.status,
                                style: const TextStyle(fontSize: 12, color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TaskDetailScreen(taskId: task.id),
                        ),
                      );
                      if (result == true) _fetchTasks();
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _primaryColor,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TaskCreateScreen()),
          );
          if (result == true) _fetchTasks();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}