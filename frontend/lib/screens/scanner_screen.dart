import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/api_service.dart';
import '../models/attendance.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final ApiService _apiService = ApiService();
  bool _isProcessing = false;
  MobileScannerController cameraController = MobileScannerController();

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final List<Barcode> barcodes = capture.barcodes;
    
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() {
          _isProcessing = true;
        });
        
        String code = barcode.rawValue!;
        try {
          Attendance attendance = await _apiService.markAttendance(code);
          if (!mounted) return;
          _showResultDialog('Success', 'Marked ${attendance.mealType} for Student ID: ${attendance.studentId}');
        } catch (e) {
          if (!mounted) return;
          _showResultDialog('Error', e.toString());
        }
        break; // Process only one code
      }
    }
  }

  void _showResultDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isProcessing = false;
              });
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mess Scanner')),
      body: MobileScanner(
        controller: cameraController,
        onDetect: _onDetect,
      ),
    );
  }
}
