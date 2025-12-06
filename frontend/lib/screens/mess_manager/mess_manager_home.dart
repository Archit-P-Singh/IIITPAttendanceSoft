import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/api_service.dart';

class MessManagerHome extends StatefulWidget {
  const MessManagerHome({super.key});

  @override
  State<MessManagerHome> createState() => _MessManagerHomeState();
}

class _MessManagerHomeState extends State<MessManagerHome> {
  Map<String, dynamic> _stats = {
    'lastMonthIncome': 0.0,
    'daysFunctioned': 0,
    'totalStudents': 0,
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  void _fetchStats() async {
    try {
      final response = await http.get(Uri.parse('${ApiService.baseUrl}/dashboard/stats'));
      if (response.statusCode == 200) {
        setState(() {
          _stats = jsonDecode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching dashboard stats: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mess Manager Dashboard')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async => _fetchStats(),
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildStatCard(
                    'Last Month Income',
                    '₹${_stats['lastMonthIncome']}',
                    Icons.currency_rupee,
                    Colors.green,
                  ),
                  _buildStatCard(
                    'Days Functioned (This Month)',
                    '${_stats['daysFunctioned']}',
                    Icons.calendar_today,
                    Colors.blue,
                  ),
                  _buildStatCard(
                    'Total Students',
                    '${_stats['totalStudents']}',
                    Icons.people,
                    Colors.orange,
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
}
