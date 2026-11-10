import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class StatisticsService {
  // Đảm bảo baseUrl khớp với cấu hình của bạn
  static const String baseUrl = 'http://10.0.2.2:3000/api/tasks';

  static Future<Map<String, dynamic>> getStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    final token =
        prefs.getString('jwt_token') ?? prefs.getString('token') ?? '';

    final response = await http.get(
      Uri.parse('$baseUrl/statistics'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['data'] as Map<String, dynamic>;
    } else {
      throw Exception(
        'Không thể tải dữ liệu thống kê. Mã lỗi: ${response.statusCode}',
      );
    }
  }
}