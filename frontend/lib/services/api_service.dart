import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/student.dart';
import '../models/attendance.dart';

class ApiService {
  // Use 10.0.2.2 for Android Emulator, localhost for iOS Simulator/Web
  static const String baseUrl = 'http://localhost:8080/api'; 

  Future<Student?> login(String rollNo) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/students'));
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        List<Student> students = body.map((dynamic item) => Student.fromJson(item)).toList();
        try {
          return students.firstWhere((student) => student.rollNo == rollNo);
        } catch (e) {
          return null;
        }
      } else {
        throw Exception('Failed to load students');
      }
    } catch (e) {
      print("Error in login: $e");
      rethrow;
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
}
