import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_widgets.dart';
import 'register_screen.dart';
import 'tasks/task_list_screen.dart'; // Import màn hình danh sách công việc

const String kBaseUrl = 'http://10.0.2.2:3000/api/auth';

class LoginScreen extends StatefulWidget {
  /// Dùng khi đăng ký xong quay lại, tự điền sẵn email
  final String? initialEmail;
  const LoginScreen({super.key, this.initialEmail});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailCtrl;
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _hidePass = true;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _showMsg(String msg, {bool error = false}) {
    final Color bg = error ? Colors.red.shade600 : Colors.green.shade600;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final res = await http.post(
        Uri.parse('$kBaseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailCtrl.text.trim(),
          'password': _passCtrl.text,
        }),
      );
      final data = jsonDecode(res.body);
      if (!mounted) return;

      if (res.statusCode == 200) {
        // Lưu JWT token (khóa jwt_token để đồng bộ với TaskService) và thông tin người dùng
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', data['token']);
        await prefs.setString('fullName', data['user']['fullName']);
        await prefs.setString('email', data['user']['email']);

        if (!mounted) return;
        _showMsg('Xin chào ${data['user']['fullName']}!');

        // CHUYỂN SANG MÀN HÌNH DANH SÁCH CÔNG VIỆC
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TaskListScreen()),
        );
      } else {
        _showMsg(data['message'] ?? 'Đăng nhập thất bại', error: true);
      }
    } catch (e) {
      if (mounted) _showMsg('Không kết nối được tới server', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _goToRegister() async {
    // Nhận email từ màn hình đăng ký trả về khi đăng ký thành công
    final email = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
    if (email != null && mounted) {
      setState(() {
        _emailCtrl.text = email;
        _passCtrl.clear();
      });
      _showMsg('Đăng ký thành công! Hãy đăng nhập.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Chào mừng trở lại',
      subtitle: 'Đăng nhập để tiếp tục',
      icon: Icons.task_alt,
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              AuthTextField(
                controller: _emailCtrl,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Vui lòng nhập email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v.trim())) {
                    return 'Email không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AuthTextField(
                controller: _passCtrl,
                label: 'Mật khẩu',
                icon: Icons.lock_outline,
                obscure: _hidePass,
                suffix: IconButton(
                  icon: Icon(
                    _hidePass ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () => setState(() => _hidePass = !_hidePass),
                ),
                validator: (v) =>
                (v == null || v.isEmpty) ? 'Vui lòng nhập mật khẩu' : null,
              ),
              const SizedBox(height: 24),
              AuthButton(
                text: 'Đăng nhập',
                loading: _loading,
                onPressed: _login,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Chưa có tài khoản?'),
                  TextButton(
                    onPressed: _goToRegister,
                    child: const Text(
                      'Đăng ký ngay',
                      style: TextStyle(
                        color: Color(0xFF6A5AE0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}