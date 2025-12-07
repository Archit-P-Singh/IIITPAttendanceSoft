import 'package:flutter/material.dart';
import '../models/student.dart';
import '../services/api_service.dart';

class ManageStudentScreen extends StatefulWidget {
  final Student? student;

  const ManageStudentScreen({super.key, this.student});

  @override
  State<ManageStudentScreen> createState() => _ManageStudentScreenState();
}

class _ManageStudentScreenState extends State<ManageStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _rollNoController = TextEditingController();
  final _deptController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    if (widget.student != null) {
      _isEditMode = true;
      _nameController.text = widget.student!.name;
      _rollNoController.text = widget.student!.rollNo;
      _deptController.text = widget.student!.department ?? '';
      _emailController.text = widget.student!.email ?? '';
      // Password not pre-filled for security, only updated if entered
    }
  }

  void _saveStudent() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        Student studentData = Student(
          studentId: _isEditMode ? widget.student!.studentId : null,
          name: _nameController.text,
          rollNo: _rollNoController.text,
          qrCode: _isEditMode ? widget.student!.qrCode : 'QR_${_rollNoController.text}',
          department: _deptController.text,
          password: _passwordController.text.isNotEmpty ? _passwordController.text : (_isEditMode ? widget.student!.password : ''),
          role: 'STUDENT',
          email: _emailController.text,
        );

        if (_isEditMode) {
          await _apiService.updateStudent(studentData);
        } else {
          await _apiService.addStudent(studentData);
        }
        
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEditMode ? 'Student updated' : 'Student added')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditMode ? 'Edit Student' : 'Add Student')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Please enter name' : null,
              ),
              TextFormField(
                controller: _rollNoController,
                decoration: const InputDecoration(labelText: 'Roll No'),
                validator: (value) => value!.isEmpty ? 'Please enter roll no' : null,
              ),
              TextFormField(
                controller: _deptController,
                decoration: const InputDecoration(labelText: 'Department'),
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: _isEditMode ? 'Password (leave blank to keep current)' : 'Password',
                ),
                obscureText: true,
                validator: (value) => (!_isEditMode && (value == null || value.isEmpty)) ? 'Please enter password' : null,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveStudent,
                      child: Text(_isEditMode ? 'Update Student' : 'Save Student'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
