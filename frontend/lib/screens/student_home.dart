import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/student.dart';
import '../services/api_service.dart';

class StudentHomeScreen extends StatefulWidget {
  final Student student;

  const StudentHomeScreen({super.key, required this.student});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  final ApiService _apiService = ApiService();
  double? _rebate;

  @override
  void initState() {
    super.initState();
    _fetchRebate();
  }

  void _fetchRebate() async {
    try {
      double rebate = await _apiService.getRebate(widget.student.studentId!);
      setState(() {
        _rebate = rebate;
      });
    } catch (e) {
      print('Error fetching rebate: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Welcome, ${widget.student.name}')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Roll No: ${widget.student.rollNo}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            QrImageView(
              data: widget.student.qrCode,
              version: QrVersions.auto,
              size: 200.0,
            ),
            const SizedBox(height: 20),
            const Text('Scan this QR at the mess counter'),
            const SizedBox(height: 40),
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text('Today\'s Rebate Status', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 10),
                    _rebate == null
                        ? const CircularProgressIndicator()
                        : Text(
                            'Rebate Amount: ₹$_rebate',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.green),
                          ),
                  ],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _fetchRebate, 
              child: const Text('Refresh Rebate')
            ),
          ],
        ),
      ),
    );
  }
}
