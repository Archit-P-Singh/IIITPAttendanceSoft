class Student {
  final int? studentId;
  final String name;
  final String rollNo;
  final String qrCode;
  final String? department;

  Student({
    this.studentId,
    required this.name,
    required this.rollNo,
    required this.qrCode,
    this.department,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      studentId: json['studentId'],
      name: json['name'],
      rollNo: json['rollNo'],
      qrCode: json['qrCode'],
      department: json['department'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'name': name,
      'rollNo': rollNo,
      'qrCode': qrCode,
      'department': department,
    };
  }
}
