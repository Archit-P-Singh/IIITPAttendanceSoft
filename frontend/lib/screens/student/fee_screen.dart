import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/api_service.dart';
import '../../models/student.dart';

class FeeScreen extends StatefulWidget {
  final Student student;

  const FeeScreen({super.key, required this.student});

  @override
  State<FeeScreen> createState() => _FeeScreenState();
}

class _FeeScreenState extends State<FeeScreen> {
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  double _messFee = 0.0;
  double _rebate = 0.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchFeeData();
  }

  void _fetchFeeData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch Mess Fee
      final feeResponse = await http.get(
        Uri.parse('${ApiService.baseUrl}/mess-fee?year=$_selectedYear&month=$_selectedMonth'),
      );
      
      if (feeResponse.statusCode == 200) {
        _messFee = double.parse(feeResponse.body);
      } else {
        _messFee = 100.0; // Default fallback
      }

      // Fetch Rebate
      final rebateResponse = await http.get(
        Uri.parse('${ApiService.baseUrl}/reports/student/${widget.student.studentId}/monthly?year=$_selectedYear&month=$_selectedMonth'),
      );

      if (rebateResponse.statusCode == 200) {
        final data = jsonDecode(rebateResponse.body);
        _rebate = data['totalRebateEarned'];
      } else {
        _rebate = 0.0;
      }

    } catch (e) {
      print("Error fetching fee data: $e");
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
    // Calculate total days in month for fee calculation if fee is daily rate
    // But backend returns monthly fee? No, backend MessFeeService returns "amount" which we assumed is monthly?
    // Wait, implementation plan said "Fixed Daily Fee: 100". 
    // MessFeeService.setFee sets a value. 
    // ReportService uses: double dailyFee = messFeeService.getFee(year, month);
    // And totalExpectedFee += daysInMonth * dailyFee;
    // So the value from MessFeeService is the DAILY rate.
    
    int daysInMonth = DateUtils.getDaysInMonth(_selectedYear, _selectedMonth);
    double totalFee = _messFee * daysInMonth;
    double netPayable = totalFee - _rebate;

    return Scaffold(
      appBar: AppBar(title: const Text('Fee & Rebate')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DropdownButton<int>(
                  value: _selectedYear,
                  items: [2024, 2025].map((e) => DropdownMenuItem(value: e, child: Text('$e'))).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedYear = val);
                      _fetchFeeData();
                    }
                  },
                ),
                DropdownButton<int>(
                  value: _selectedMonth,
                  items: List.generate(12, (index) => index + 1)
                      .map((e) => DropdownMenuItem(value: e, child: Text(_getMonthName(e))))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedMonth = val);
                      _fetchFeeData();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildRow('Daily Fee Rate:', '₹$_messFee'),
                          _buildRow('Days in Month:', '$daysInMonth'),
                          const Divider(),
                          _buildRow('Total Mess Fee:', '₹${totalFee.toStringAsFixed(2)}'),
                          _buildRow('Total Rebate:', '- ₹${_rebate.toStringAsFixed(2)}', color: Colors.green),
                          const Divider(),
                          _buildRow('Net Payable:', '₹${netPayable.toStringAsFixed(2)}', isBold: true),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: 16)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: 16, color: color)),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
