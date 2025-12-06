import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/api_service.dart';

class StudentStatsScreen extends StatefulWidget {
  const StudentStatsScreen({super.key});

  @override
  State<StudentStatsScreen> createState() => _StudentStatsScreenState();
}

class _StudentStatsScreenState extends State<StudentStatsScreen> {
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  Map<String, int> _mealStats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  void _fetchStats() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/reports/stats/meal-wise?year=$_selectedYear&month=$_selectedMonth'),
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          _mealStats = data.map((key, value) => MapEntry(key, (value as num).toInt()));
        });
      }
    } catch (e) {
      print("Error fetching meal stats: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Statistics')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<int>(
              value: _selectedMonth,
              items: List.generate(12, (index) => index + 1)
                  .map((e) => DropdownMenuItem(value: e, child: Text('Month $e')))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedMonth = val);
                  _fetchStats();
                }
              },
            ),
            const SizedBox(height: 20),
            const Text('Meal-wise Distribution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : PieChart(
                      PieChartData(
                        sections: _getSections(),
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                      ),
                    ),
            ),
            const SizedBox(height: 20),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _getSections() {
    if (_mealStats.isEmpty) return [];
    
    // Define colors for meals
    final colors = {
      'BREAKFAST': Colors.orange,
      'LUNCH': Colors.blue,
      'TEA': Colors.brown,
      'DINNER': Colors.purple,
    };

    return _mealStats.entries.map((entry) {
      return PieChartSectionData(
        color: colors[entry.key] ?? Colors.grey,
        value: entry.value.toDouble(),
        title: '${entry.value}',
        radius: 50,
        titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  Widget _buildLegend() {
    final colors = {
      'BREAKFAST': Colors.orange,
      'LUNCH': Colors.blue,
      'TEA': Colors.brown,
      'DINNER': Colors.purple,
    };

    return Wrap(
      spacing: 16,
      children: colors.entries.map((entry) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 16, height: 16, color: entry.value),
            const SizedBox(width: 4),
            Text(entry.key),
          ],
        );
      }).toList(),
    );
  }
}
