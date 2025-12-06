import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/student.dart';
import '../auth/forgot_password_screen.dart';
import '../login_screen.dart';

class SettingsScreen extends StatelessWidget {
  final Student student;

  const SettingsScreen({super.key, required this.student});

  void _logout(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: themeProvider.themeMode == ThemeMode.dark,
            onChanged: (value) {
              themeProvider.toggleTheme(value);
            },
            secondary: const Icon(Icons.dark_mode),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.lock_reset),
            title: const Text('Reset Password'),
            onTap: () {
               // Navigate to Forgot Password Screen, pre-filling roll no if possible, 
               // or just let them enter it. The user requested "Reset Password" in settings
               // which usually implies they know the old password or just want to change it.
               // But the requirement says "Reset Password option" -> "OTP Verification" -> "Reset Password".
               // So we can reuse the Forgot Password flow.
               Navigator.push(
                 context,
                 MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
               );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}
