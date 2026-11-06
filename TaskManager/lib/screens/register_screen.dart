import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'auth_widgets.dart';
import 'login_screen.dart' show kBaseUrl;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  bool _hidePass = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final res = await http.post(
        Uri.parse('$kBaseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          // Nếu backend dùng tên field khác (vd: fullName) thì đổi key ở đây
          'name': _nameCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
          'password': _passCtrl.text,
        }),
      );
      final data = jsonDecode(res.body);
      if (!mounted) return;
      if (res.statusCode == 200 || res.statusCode == 201) {
        // Thành công -> quay về màn hình đăng nhập, trả email về để điền sẵn
        Navigator.pop(context, _emailCtrl.text.trim());
      } else {
        _showError(data['message'] ?? 'Đăng ký thất bại');
      }
    } catch (e) {
      if (mounted) _showError('Không kết nối được tới server');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Tạo tài khoản',
      subtitle: 'Điền thông tin để bắt đầu',
      icon: Icons.person_add_alt_1,
      showBack: true,
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              AuthTextField(
                controller: _nameCtrl,
                label: 'Họ và tên',
                icon: Icons.person_outline,
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Vui lòng nhập họ tên' : null,
              ),
              const SizedBox(height: 16),
              AuthTextField(
                controller: _emailCtrl,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Vui lòng nhập email';
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
                  icon: Icon(_hidePass ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _hidePass = !_hidePass),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Vui lòng nhập mật khẩu';
                  if (v.length < 6) return 'Mật khẩu tối thiểu 6 ký tự';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AuthTextField(
                controller: _confirmCtrl,
                label: 'Nhập lại mật khẩu',
                icon: Icons.lock_reset,
                obscure: _hidePass,
                validator: (v) =>
                v != _passCtrl.text ? 'Mật khẩu không khớp' : null,
              ),
              const SizedBox(height: 24),
              AuthButton(text: 'Đăng ký', loading: _loading, onPressed: _register),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Đã có tài khoản?'),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Đăng nhập',
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