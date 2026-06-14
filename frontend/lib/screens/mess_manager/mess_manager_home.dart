import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
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

  void _showPredictionDialog() {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    String selectedMeal = 'LUNCH';
    int? predictedHeadcount;
    bool isLoadingPrediction = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Predict Headcount'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Select Date:'),
                  ElevatedButton(
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (picked != null) {
                        setDialogState(() {
                          selectedDate = picked;
                          predictedHeadcount = null;
                        });
                      }
                    },
                    child: Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                  ),
                  const SizedBox(height: 20),
                  const Text('Select Meal:'),
                  DropdownButton<String>(
                    value: selectedMeal,
                    items: ['BREAKFAST', 'LUNCH', 'TEA', 'DINNER']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          selectedMeal = val;
                          predictedHeadcount = null;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  if (isLoadingPrediction)
                    const CircularProgressIndicator()
                  else if (predictedHeadcount != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          const Text('Expected Headcount', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('$predictedHeadcount', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                    )
                  else
                    ElevatedButton(
                      onPressed: () async {
                        setDialogState(() => isLoadingPrediction = true);
                        try {
                          String dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
                          final response = await http.get(
                            Uri.parse('${ApiService.baseUrl}/manager/prediction?date=$dateStr&mealType=$selectedMeal'),
                          );
                          if (response.statusCode == 200) {
                            final data = jsonDecode(response.body);
                            setDialogState(() {
                              predictedHeadcount = data['predictedHeadcount'];
                            });
                          }
                        } catch (e) {
                          print("Error fetching prediction: $e");
                        } finally {
                          setDialogState(() => isLoadingPrediction = false);
                        }
                      },
                      child: const Text('Calculate Prediction'),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          }
        );
      },
    );
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
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.analytics),
                    label: const Text('Predict Tomorrow\'s Food Quantity'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    onPressed: _showPredictionDialog,
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
