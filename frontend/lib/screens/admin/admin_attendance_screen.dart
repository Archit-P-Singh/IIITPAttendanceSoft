import 'package:flutter/material.dart';
import '../../models/attendance.dart';
import '../../models/student.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart';

class AdminAttendanceScreen extends StatefulWidget {
  final Student? student; // Optional: if provided, show only this student's attendance

  const AdminAttendanceScreen({super.key, this.student});

  @override
  State<AdminAttendanceScreen> createState() => _AdminAttendanceScreenState();
}

class _AdminAttendanceScreenState extends State<AdminAttendanceScreen> {
  final ApiService _apiService = ApiService();
  List<Attendance> _attendanceList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAttendance();
  }

  void _fetchAttendance() async {
    setState(() => _isLoading = true);
    try {
      List<Attendance> data;
      if (widget.student != null) {
        data = await _apiService.getAttendanceByStudent(widget.student!.studentId!);
      } else {
        data = await _apiService.getAllAttendance();
      }
      
      // Sort by date desc
      data.sort((a, b) => b.date.compareTo(a.date));

      setState(() {
        _attendanceList = data;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching attendance: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.student != null ? 'Attendance: ${widget.student!.name}' : 'All Attendance'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _attendanceList.isEmpty
              ? const Center(child: Text('No attendance records found.'))
              : ListView.builder(
                  itemCount: _attendanceList.length,
                  itemBuilder: (context, index) {
                    final record = _attendanceList[index];
                    return ListTile(
                      leading: Icon(
                        record.present ? Icons.check_circle : Icons.cancel,
                        color: record.present ? Colors.green : Colors.red,
                      ),
                      title: Text(record.date),
                      subtitle: Text(record.mealType.toString().split('.').last),
                    );
                  },
                ),
    );
  }
}
