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
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final ApiService _apiService = ApiService();
  
  String _role = 'STUDENT';
  String _department = 'CSE';
  String _hostel = 'BH1';
  int _year = 1;
  int _semester = 1;
  
  bool _isLoading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    if (widget.student != null) {
      _isEditMode = true;
      _nameController.text = widget.student!.name;
      _rollNoController.text = widget.student!.rollNo;
      _passwordController.text = ''; // Don't show password
      _emailController.text = widget.student!.email ?? '';
      _role = widget.student!.role ?? 'STUDENT';
      _department = widget.student!.department ?? 'CSE';
      _hostel = widget.student!.hostel ?? 'BH1';
      _year = widget.student!.year ?? 1;
      _semester = widget.student!.semester ?? 1;
    }
    
    // Listeners for auto-email
    _rollNoController.addListener(_generateEmail);
  }

  void _generateEmail() {
    if (_role == 'STUDENT') {
      String roll = _rollNoController.text.trim();
      if (roll.isNotEmpty) {
        _emailController.text = '$roll@${_department.toLowerCase()}.iiitp.ac.in';
      }
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
          department: _department,
          password: _passwordController.text.isNotEmpty ? _passwordController.text : (_isEditMode ? widget.student!.password : ''),
          role: _role,
          email: _emailController.text,
          year: _year,
          semester: _semester,
          hostel: _hostel,
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
      appBar: AppBar(title: Text(_isEditMode ? 'Edit User' : 'Add User')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _role,
                decoration: const InputDecoration(labelText: 'Role'),
                items: ['STUDENT', 'MESS_MANAGER', 'ADMIN']
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _role = val!;
                    _generateEmail();
                  });
                },
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Please enter name' : null,
              ),
              TextFormField(
                controller: _rollNoController,
                decoration: const InputDecoration(labelText: 'Roll No / Username'),
                validator: (value) => value!.isEmpty ? 'Please enter roll no' : null,
              ),
              if (_role == 'STUDENT') ...[
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _department,
                        decoration: const InputDecoration(labelText: 'Department'),
                        items: ['CSE', 'ECE']
                            .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            _department = val!;
                            _generateEmail();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _hostel,
                        decoration: const InputDecoration(labelText: 'Hostel'),
                        items: ['BH1', 'BH2', 'GH1']
                            .map((h) => DropdownMenuItem(value: h, child: Text(h)))
                            .toList(),
                        onChanged: (val) => setState(() => _hostel = val!),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _year,
                        decoration: const InputDecoration(labelText: 'Year'),
                        items: [1, 2, 3, 4]
                            .map((y) => DropdownMenuItem(value: y, child: Text('Year $y')))
                            .toList(),
                        onChanged: (val) => setState(() => _year = val!),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _semester,
                        decoration: const InputDecoration(labelText: 'Semester'),
                        items: List.generate(8, (i) => i + 1)
                            .map((s) => DropdownMenuItem(value: s, child: Text('Sem $s')))
                            .toList(),
                        onChanged: (val) => setState(() => _semester = val!),
                      ),
                    ),
                  ],
                ),
              ],
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                readOnly: _role == 'STUDENT', // Auto-generated for students
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
                      child: Text(_isEditMode ? 'Update User' : 'Save User'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
