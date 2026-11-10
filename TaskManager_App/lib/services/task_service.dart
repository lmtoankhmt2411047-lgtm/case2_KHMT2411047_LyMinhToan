import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../models/task_activity.dart';

class TaskService {
  // 10.0.2.2 dùng cho Android Emulator kết nối tới localhost máy tính
  static const String baseUrl = 'http://10.0.2.2:3000/api/tasks';

  // Helper lấy Header kèm JWT Token từ SharedPreferences
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // B1: Tạo công việc mới (POST /api/tasks)
  static Future<bool> createTask({
    required String title,
    required String description,
    DateTime? startDate,
    DateTime? dueDate,
    required String priority,
    required String status,
  }) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
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

  // B2: Lấy danh sách công việc (GET /api/tasks)
  static Future<List<Task>> getTasks() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['data'];
      return data
          .map((json) => Task.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Không thể tải danh sách công việc');
    }
  }

  // B2: Lấy chi tiết công việc theo ID (GET /api/tasks/:id)
  static Future<Task> getTaskById(String id) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/$id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return Task.fromJson(body['data'] as Map<String, dynamic>);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Không thể tải chi tiết công việc');
    }
  }

  // B3: Cập nhật công việc (PUT /api/tasks/:id)
  static Future<bool> updateTask(
      String id,
      Map<String, dynamic> updateData,
      ) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: headers,
      body: jsonEncode(updateData),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Không thể cập nhật công việc');
    }
  }

  // B3: Xóa công việc (DELETE /api/tasks/:id)
  static Future<bool> deleteTask(String id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Không thể xóa công việc');
    }
  }

  // B4 / E: Lấy lịch sử hoạt động của 1 công việc (GET /api/tasks/:id/activities)
  static Future<List<TaskActivity>> getTaskActivities(String taskId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/$taskId/activities'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['data'];
      return data
          .map((json) => TaskActivity.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Không thể tải lịch sử hoạt động');
    }
  }

  // C1: Giao công việc cho thành viên qua Email (POST /api/tasks/:id/assign)
  static Future<bool> assignTask({
    required String taskId,
    required String email,
    bool isPrimary = false,
  }) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/$taskId/assign'),
      headers: headers,
      body: jsonEncode({
        'email': email,
        'isPrimary': isPrimary,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Không thể giao công việc');
    }
  }

  // C2: Chia sẻ công việc và cấp quyền viewer/editor (POST /api/tasks/:id/share)
  static Future<bool> shareTask({
    required String taskId,
    required String email,
    required String role,
  }) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/$taskId/share'),
      headers: headers,
      body: jsonEncode({
        'email': email,
        'role': role,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Không thể chia sẻ công việc');
    }
  }

  // C3: Thu hồi quyền chia sẻ (DELETE /api/tasks/:id/share/:userId)
  static Future<bool> removeShareAccess(String taskId, String userId) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/$taskId/share/$userId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Không thể thu hồi quyền truy cập');
    }
  }
}