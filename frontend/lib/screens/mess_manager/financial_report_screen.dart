import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/api_service.dart';

class FinancialReportScreen extends StatefulWidget {
  const FinancialReportScreen({super.key});

  @override
  State<FinancialReportScreen> createState() => _FinancialReportScreenState();
}

class _FinancialReportScreenState extends State<FinancialReportScreen> {
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  Map<String, double> _chartData = {};
  bool _isLoading = true;
  bool _canUpdateFee = false;
  final TextEditingController _feeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
    _checkFeeUpdatePermission();
  }

  void _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/reports/financial/daily-chart?year=$_selectedYear&month=$_selectedMonth'),
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          _chartData = data.map((key, value) => MapEntry(key, (value as num).toDouble()));
        });
      }
    } catch (e) {
      print("Error fetching chart data: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _checkFeeUpdatePermission() async {
    try {
      final response = await http.get(Uri.parse('${ApiService.baseUrl}/config/ALLOW_FEE_UPDATE'));
      if (response.statusCode == 200) {
        setState(() {
          _canUpdateFee = response.body == 'true';
        });
      }
    } catch (e) {
      print("Error checking fee permission: $e");
    }
  }

  void _updateFee() async {
    if (_feeController.text.isEmpty) return;
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/mess-fee'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'year': _selectedYear,
          'month': _selectedMonth,
          'amount': double.parse(_feeController.text),
        }),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fee Updated Successfully')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${response.body}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Financial Report')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Month/Year Dropdown (Simplified)
            Row(
              children: [
                DropdownButton<int>(
                  value: _selectedMonth,
                  items: List.generate(12, (index) => index + 1)
                      .map((e) => DropdownMenuItem(value: e, child: Text('Month $e')))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedMonth = val);
                      _fetchData();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Chart
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: _chartData.values.isEmpty ? 100 : _chartData.values.reduce((a, b) => a > b ? a : b) * 1.2,
                        barTouchData: BarTouchData(enabled: true),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                // Show day number for simplicity
                                int index = value.toInt();
                                if (index >= 0 && index < _chartData.length) {
                                  // Assuming sorted keys, but map order isn't guaranteed in Dart unless LinkedHashMap (default)
                                  // Backend sent TreeMap so keys are sorted dates.
                                  String date = _chartData.keys.elementAt(index);
                                  return Text(date.split('-')[2], style: const TextStyle(fontSize: 10));
                                }
                                return const Text('');
                              },
                            ),
                          ),
                        ),
                        barGroups: _chartData.entries.toList().asMap().entries.map((entry) {
                          return BarChartGroupData(
                            x: entry.key,
                            barRods: [
                              BarChartRodData(toY: entry.value.value, color: Colors.blue),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
            ),
            const SizedBox(height: 20),
            // Fee Update Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text('Update Mess Fee (Monthly)', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _feeController,
                      decoration: const InputDecoration(labelText: 'New Fee Amount'),
                      keyboardType: TextInputType.number,
                      enabled: _canUpdateFee,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _canUpdateFee ? _updateFee : null,
                      child: Text(_canUpdateFee ? 'Update Fee' : 'Update Disabled'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
