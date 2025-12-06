import 'package:flutter/material.dart';
import '../../models/student.dart';
import 'mess_manager_home.dart';
import 'financial_report_screen.dart';
import 'student_stats_screen.dart';
import '../scanner_screen.dart';
import '../student/settings_screen.dart';

class MessManagerMainScreen extends StatefulWidget {
  final Student manager;

  const MessManagerMainScreen({super.key, required this.manager});

  @override
  State<MessManagerMainScreen> createState() => _MessManagerMainScreenState();
}

class _MessManagerMainScreenState extends State<MessManagerMainScreen> {
  int _currentIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const MessManagerHome(),
      const FinancialReportScreen(),
      const ScannerScreen(),
      const StudentStatsScreen(),
      SettingsScreen(student: widget.manager),
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
            icon: Icon(Icons.attach_money_outlined),
            selectedIcon: Icon(Icons.attach_money),
            label: 'Financial',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner_outlined),
            selectedIcon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline),
            selectedIcon: Icon(Icons.pie_chart),
            label: 'Stats',
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
