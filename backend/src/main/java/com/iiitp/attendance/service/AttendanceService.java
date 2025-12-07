package com.iiitp.attendance.service;

import com.iiitp.attendance.model.Attendance;
import com.iiitp.attendance.model.MealType;
import com.iiitp.attendance.model.Student;
import com.iiitp.attendance.repository.AttendanceRepository;
import com.iiitp.attendance.repository.StudentRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.Optional;

@Service
public class AttendanceService {

    private final AttendanceRepository attendanceRepository;
    private final StudentRepository studentRepository;

    public AttendanceService(AttendanceRepository attendanceRepository, StudentRepository studentRepository) {
        this.attendanceRepository = attendanceRepository;
        this.studentRepository = studentRepository;
    }

    public Attendance markAttendance(String qrCode) {
        Student student = studentRepository.findByQrCode(qrCode)
                .orElseThrow(() -> new RuntimeException("Student not found with QR Code: " + qrCode));

        MealType currentMeal = getCurrentMealType();
        if (currentMeal == null) {
            throw new RuntimeException("No meal is currently being served.");
        }

        LocalDate today = LocalDate.now();

        // Check if already marked
        boolean alreadyMarked = attendanceRepository.findByStudentAndDate(student, today).stream()
                .anyMatch(a -> a.getMealType() == currentMeal);

        if (alreadyMarked) {
            throw new RuntimeException("Attendance already marked for " + currentMeal);
        }

        Attendance attendance = new Attendance();
        attendance.setStudent(student);
        attendance.setDate(today);
        attendance.setMealType(currentMeal);
        attendance.setPresent(true);

        return attendanceRepository.save(attendance);
    }

    private MealType getCurrentMealType() {
        LocalTime now = LocalTime.now();
        if (now.isAfter(LocalTime.of(7, 0)) && now.isBefore(LocalTime.of(10, 0))) {
            return MealType.BREAKFAST;
        } else if (now.isAfter(LocalTime.of(12, 0)) && now.isBefore(LocalTime.of(15, 0))) {
            return MealType.LUNCH;
        } else if (now.isAfter(LocalTime.of(16, 0)) && now.isBefore(LocalTime.of(18, 0))) {
            return MealType.TEA;
        } else if (now.isAfter(LocalTime.of(19, 0)) && now.isBefore(LocalTime.of(22, 0))) {
            return MealType.DINNER;
        }
        return null;
    }

    public java.util.List<Attendance> getAttendanceByStudent(int studentId) {
        Student student = studentRepository.findById(studentId)
                .orElseThrow(() -> new RuntimeException("Student not found"));
        return attendanceRepository.findByStudent(student);
    }

    public java.util.List<Attendance> getAllAttendance() {
        return attendanceRepository.findAll();
    }
}
