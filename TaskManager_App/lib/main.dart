import 'package:flutter/material.dart';
import 'screens/tasks/task_list_screen.dart'; // Import màn hình danh sách công việc

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản Lý Công Việc',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const TaskListScreen(), // Đặt màn hình danh sách làm màn hình chính
    );
  }
}