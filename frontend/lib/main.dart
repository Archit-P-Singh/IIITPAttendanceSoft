import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'providers/theme_provider.dart';
import 'services/api_service.dart';
import 'models/student.dart';
import 'screens/student/student_main_screen.dart';
import 'screens/admin_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final ApiService apiService = ApiService();
  final Student? user = await apiService.getUser();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: MyApp(initialUser: user),
    ),
  );
}

class MyApp extends StatelessWidget {
  final Student? initialUser;

  const MyApp({super.key, this.initialUser});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'IIITP Mess Attendance',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
          ),
          themeMode: themeProvider.themeMode,
          home: _getInitialScreen(),
        );
      },
    );
  }

  Widget _getInitialScreen() {
    if (initialUser != null) {
      if (initialUser!.role == 'ADMIN') {
        return const AdminDashboard();
      } else {
        return StudentMainScreen(student: initialUser!);
      }
    }
    return const LoginScreen();
  }
}

