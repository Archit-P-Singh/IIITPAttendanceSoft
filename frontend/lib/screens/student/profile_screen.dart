import 'package:flutter/material.dart';
import '../../models/student.dart';

class ProfileScreen extends StatelessWidget {
  final Student student;

  const ProfileScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 20),
            _buildProfileItem(Icons.person, 'Name', student.name),
            _buildProfileItem(Icons.numbers, 'Roll No', student.rollNo),
            _buildProfileItem(Icons.school, 'Department', student.department ?? 'N/A'),
            _buildProfileItem(Icons.email, 'Email', student.email ?? 'N/A'),
            _buildProfileItem(Icons.badge, 'Role', student.role ?? 'STUDENT'),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String label, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
