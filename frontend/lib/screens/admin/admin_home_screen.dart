import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/api_service.dart';
import '../scanner_screen.dart';
import '../manage_student_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  Map<String, dynamic> _dashboardStats = {};
  Map<String, dynamic> _attendanceStats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  void _fetchStats() async {
    try {
      // Fetch Dashboard Stats (Total Students)
      final dashboardResponse = await http.get(Uri.parse('${ApiService.baseUrl}/dashboard/stats'));
      
      // Fetch Today's Attendance Stats
      final date = DateTime.now().toIso8601String().split('T')[0];
      final attendanceResponse = await http.get(Uri.parse('${ApiService.baseUrl}/reports/attendance/daily?date=$date'));

      if (dashboardResponse.statusCode == 200 && attendanceResponse.statusCode == 200) {
        setState(() {
          _dashboardStats = jsonDecode(dashboardResponse.body);
          _attendanceStats = jsonDecode(attendanceResponse.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching admin home stats: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalAttendanceToday = 0;
    if (_attendanceStats.isNotEmpty) {
      // _attendanceStats is Map<String, Long> (meal -> count)
      // Actually, the backend returns Map<String, Long> now after my fix.
      // Let's sum values.
      _attendanceStats.forEach((key, value) {
        totalAttendanceToday += (value as num).toInt();
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Home')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async => _fetchStats(),
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildStatCard(
                    'Total Students',
                    '${_dashboardStats['totalStudents'] ?? 0}',
                    Icons.people,
                    Colors.blue,
                  ),
                  _buildStatCard(
                    'Attendance Today',
                    '$totalAttendanceToday',
                    Icons.check_circle,
                    Colors.green,
                  ),
                  const SizedBox(height: 20),
                  const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          context,
                          'Scan QR',
                          Icons.qr_code_scanner,
                          Colors.purple,
                          () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ScannerScreen())),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildActionCard(
                          context,
                          'Add Student',
                          Icons.person_add,
                          Colors.orange,
                          () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageStudentScreen())),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              radius: 30,
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 5),
                Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
