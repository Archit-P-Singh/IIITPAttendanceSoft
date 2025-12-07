import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/student.dart';
import '../../services/api_service.dart';

class AdminQrViewScreen extends StatefulWidget {
  final Student student;

  const AdminQrViewScreen({super.key, required this.student});

  @override
  State<AdminQrViewScreen> createState() => _AdminQrViewScreenState();
}

class _AdminQrViewScreenState extends State<AdminQrViewScreen> {
  late Student _student;
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _student = widget.student;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('QR Code: ${_student.name}')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: QrImageView(
                data: _student.qrCode,
                version: QrVersions.auto,
                size: 250.0,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _student.qrCode,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
