class Attendance {
  final int? attendanceId;
  final int studentId;
  final String date;
  final String mealType;
  final bool present;

  Attendance({
    this.attendanceId,
    required this.studentId,
    required this.date,
    required this.mealType,
    required this.present,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      attendanceId: json['attendanceId'],
      studentId: json['student']['studentId'], // Accessing nested student object
      date: json['date'],
      mealType: json['mealType'],
      present: json['present'],
    );
  }
}
