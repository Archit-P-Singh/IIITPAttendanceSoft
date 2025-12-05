package com.iiitp.attendance.controller;

import com.iiitp.attendance.model.Attendance;
import com.iiitp.attendance.model.Student;
import com.iiitp.attendance.service.AttendanceService;
import com.iiitp.attendance.service.RebateService;
import com.iiitp.attendance.service.StudentService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;

@RestController
@RequestMapping("/api/attendance")
public class AttendanceController {

    private final AttendanceService attendanceService;
    private final RebateService rebateService;
    private final StudentService studentService;

    public AttendanceController(AttendanceService attendanceService, RebateService rebateService,
            StudentService studentService) {
        this.attendanceService = attendanceService;
        this.rebateService = rebateService;
        this.studentService = studentService;
    }

    @PostMapping("/mark")
    public ResponseEntity<?> markAttendance(@RequestParam String qrCode) {
        try {
            Attendance attendance = attendanceService.markAttendance(qrCode);
            return ResponseEntity.ok(attendance);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @GetMapping("/rebate/{studentId}")
    public ResponseEntity<?> getRebate(@PathVariable Integer studentId,
            @RequestParam(required = false) LocalDate date) {
        if (date == null) {
            date = LocalDate.now();
        }

        Student student = studentService.getStudentById(studentId)
                .orElseThrow(() -> new RuntimeException("Student not found"));

        double rebate = rebateService.calculateDailyRebate(student, date);
        return ResponseEntity.ok(rebate);
    }
}
