import 'package:flutter/material.dart';
import 'admin_home_screen.dart';
import 'admin_student_list_screen.dart';
import 'admin_attendance_screen.dart';
import '../student/settings_screen.dart';
import '../../models/student.dart'; // Needed for SettingsScreen which expects a Student object

class AdminMainScreen extends StatefulWidget {
  // Admin doesn't necessarily have a 'Student' object in the same way, 
  // but SettingsScreen expects one. We might need to pass a dummy or the admin user object if available.
  // LoginScreen passes 'student' object even for Admin.
  final Student admin;

  const AdminMainScreen({super.key, required this.admin});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const AdminHomeScreen(),
      const AdminStudentListScreen(),
      const AdminAttendanceScreen(),
      SettingsScreen(student: widget.admin),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outlined),
            selectedIcon: Icon(Icons.people),
            label: 'Students',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Attendance',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
