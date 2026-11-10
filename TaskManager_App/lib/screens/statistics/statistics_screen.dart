import 'package:flutter/material.dart';
import '../../services/statistics_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, dynamic>? _statsData;

  final Color _primaryColor = const Color(0xFF6A5AE0);

  @override
  void initState() {
    super.initState();
    _fetchStatistics();
  }

  Future<void> _fetchStatistics() async {
    try {
      final data = await StatisticsService.getStatistics();
      setState(() {
        _statsData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Widget _buildStatCard(String title, String count, Color color, IconData icon) {
    return Card(
      elevation: 3,
      shadowColor: color.withOpacity(0.3), // Tạm dùng withOpacity cho an toàn
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
            ),
            const SizedBox(height: 4),
            Text(
              count,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FB),
      appBar: AppBar(
        title: const Text('Thống kê công việc', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: _primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _primaryColor))
          : _errorMessage.isNotEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(_errorMessage, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
        ),
      )
          : _statsData == null
          ? const Center(child: Text('Không có dữ liệu'))
          : RefreshIndicator(
        onRefresh: _fetchStatistics,
        color: _primaryColor,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Theo trạng thái', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                _buildStatCard('Tổng số', '${_statsData!['statusStats']['total']}', Colors.blue, Icons.list_alt),
                _buildStatCard('Chưa làm', '${_statsData!['statusStats']['pending']}', Colors.orange, Icons.pending_actions),
                _buildStatCard('Đang làm', '${_statsData!['statusStats']['inProgress']}', Colors.purple, Icons.autorenew),
                _buildStatCard('Hoàn thành', '${_statsData!['statusStats']['completed']}', Colors.green, Icons.check_circle),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Theo tiến độ & Vai trò', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                _buildStatCard('Quá hạn', '${_statsData!['deadlineStats']['overdue']}', Colors.red, Icons.warning_amber_rounded),
                _buildStatCard('Sắp đến hạn', '${_statsData!['deadlineStats']['dueSoon']}', Colors.amber.shade700, Icons.timer_outlined),
                _buildStatCard('Đang quản lý', '${_statsData!['roleStats']['managing']}', Colors.teal, Icons.admin_panel_settings),
                _buildStatCard('Được giao', '${_statsData!['roleStats']['assigned']}', Colors.indigo, Icons.assignment_ind),
              ],
            ),
            const SizedBox(height: 20), // Khoảng trống dưới cùng
          ],
        ),
      ),
    );
  }
}