import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/student.dart';
import '../models/attendance.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Use 10.0.2.2 for Android Emulator, localhost for iOS Simulator/Web
  static const String baseUrl = 'http://localhost:8080/api'; 

  Future<Student?> login(String rollNo, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'rollNo': rollNo, 'password': password}),
      );
      
      if (response.statusCode == 200) {
        return Student.fromJson(jsonDecode(response.body));
      } else {
        return null;
      }
    } catch (e) {
      print("Error in login: $e");
      rethrow;
    }
  }

  Future<List<Student>> getAllStudents() async {
    final response = await http.get(Uri.parse('$baseUrl/students'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Student.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load students');
    }
  }

  Future<Student> addStudent(Student student) async {
    final response = await http.post(
      Uri.parse('$baseUrl/students'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(student.toJson()),
    );
    if (response.statusCode == 200) {
      return Student.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add student');
    }
  }

  Future<void> deleteStudent(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/students/$id'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete student');
    }
  }

  Future<Attendance> markAttendance(String qrCode) async {
    final response = await http.post(
      Uri.parse('$baseUrl/attendance/mark?qrCode=$qrCode'),
    );
    if (response.statusCode == 200) {
      return Attendance.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to mark attendance: ${response.body}');
    }
  }

  Future<double> getRebate(int studentId) async {
    final response = await http.get(Uri.parse('$baseUrl/attendance/rebate/$studentId'));
    if (response.statusCode == 200) {
      return double.parse(response.body.toString());
    } else {
      throw Exception('Failed to get rebate');
    }
  }
  Future<bool> verifyOtp(String rollNo, String otp) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'rollNo': rollNo, 'otp': otp}),
    );
    return response.statusCode == 200;
  }

  Future<void> saveUser(Student student) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(student.toJson()));
    await prefs.setString('login_time', DateTime.now().toIso8601String());
  }

  Future<Student?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user');
    final loginTimeStr = prefs.getString('login_time');

    if (userStr != null && loginTimeStr != null) {
      final loginTime = DateTime.parse(loginTimeStr);
      final now = DateTime.now();
      // Check if session is valid (e.g., 30 days)
      if (now.difference(loginTime).inDays < 30) {
        return Student.fromJson(jsonDecode(userStr));
      } else {
        await logout(); // Expired
      }
    }
    return null;
  }

  Future<Student> updateStudent(Student student) async {
    final response = await http.put(
      Uri.parse('$baseUrl/students/${student.studentId}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(student.toJson()),
    );
    if (response.statusCode == 200) {
      return Student.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update student');
    }
  }

  Future<Student> regenerateQr(int studentId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/students/$studentId/regenerate-qr'),
    );
    if (response.statusCode == 200) {
      return Student.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to regenerate QR');
    }
  }

  Future<List<Attendance>> getAttendanceByStudent(int studentId) async {
    final response = await http.get(Uri.parse('$baseUrl/attendance/student/$studentId'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Attendance.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load attendance');
    }
  }

  Future<List<Attendance>> getAllAttendance() async {
    final response = await http.get(Uri.parse('$baseUrl/attendance/all'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Attendance.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load all attendance');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    await prefs.remove('login_time');
  }
}
