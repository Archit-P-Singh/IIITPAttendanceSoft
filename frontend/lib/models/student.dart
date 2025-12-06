class Student {
  final int? studentId;
  final String name;
  final String rollNo;
  final String qrCode;
  final String? department;
  final String? password;
  final String? role;

  Student({
    this.studentId,
    required this.name,
    required this.rollNo,
    required this.qrCode,
    this.department,
    this.password,
    this.role,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      studentId: json['studentId'],
      name: json['name'],
      rollNo: json['rollNo'],
      qrCode: json['qrCode'],
      department: json['department'],
      password: json['password'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'name': name,
      'rollNo': rollNo,
      'qrCode': qrCode,
      'department': department,
      'password': password,
      'role': role,
    };
  }
}
