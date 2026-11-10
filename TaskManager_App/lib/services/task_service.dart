import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TaskService {
  // Thay đổi IP nếu chạy máy thật (VD: http://192.168.1.x:3000/api/tasks)
  static const String baseUrl = 'http://10.0.2.2:3000/api/tasks';

  static Future<bool> createTask({
    required String title,
    required String description,
    DateTime? startDate,
    DateTime? dueDate,
    required String priority,
    required String status,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token'); // Lấy token xác thực đã lưu lúc đăng nhập

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'title': title,
        'description': description,
        'startDate': startDate?.toIso8601String(),
        'dueDate': dueDate?.toIso8601String(),
        'priority': priority,
        'status': status,
      }),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Không thể tạo công việc');
    }
  }
}