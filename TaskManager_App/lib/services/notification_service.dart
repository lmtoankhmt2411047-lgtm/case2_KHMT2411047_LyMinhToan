import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';

class NotificationService {
  static const String baseUrl = 'http://10.0.2.2:3000/api/notifications';

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token =
        prefs.getString('jwt_token') ?? prefs.getString('token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<List<NotificationModel>> getNotifications() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(baseUrl), headers: headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['data'] ?? [];
      return data
          .map((json) =>
          NotificationModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Không thể tải danh sách thông báo');
    }
  }

  static Future<void> markAsRead(String id) async {
    final headers = await _getHeaders();
    await http.patch(Uri.parse('$baseUrl/$id/read'), headers: headers);
  }
}