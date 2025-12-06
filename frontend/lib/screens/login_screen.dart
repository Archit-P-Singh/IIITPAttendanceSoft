import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/student.dart';
import 'student_home.dart';
import 'admin_dashboard.dart';
import 'scanner_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _rollNoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  void _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String rollNo = _rollNoController.text.trim();
      String password = _passwordController.text.trim();

      // Special case for mess staff scanner (still kept for backward compat if needed, or can be removed)
      if (rollNo == 'scanner' && password == 'scanner') {
         Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ScannerScreen()),
        );
        return;
      }

      Student? student = await _apiService.login(rollNo, password);
      
      if (!mounted) return;

      if (student != null) {
        if (student.role == 'ADMIN') {
           Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminDashboard()),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => StudentHomeScreen(student: student)),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid credentials')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('IIITP Mess Attendance')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _rollNoController,
              decoration: const InputDecoration(
                labelText: 'Roll No / Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    child: const Text('Login'),
                  ),
          ],
        ),
      ),
    );
  }
}
