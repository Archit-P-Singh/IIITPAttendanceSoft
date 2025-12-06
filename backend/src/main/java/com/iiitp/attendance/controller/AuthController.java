package com.iiitp.attendance.controller;

import com.iiitp.attendance.model.Student;
import com.iiitp.attendance.repository.StudentRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final StudentRepository studentRepository;

    private final com.iiitp.attendance.service.EmailService emailService;

    public AuthController(StudentRepository studentRepository, com.iiitp.attendance.service.EmailService emailService) {
        this.studentRepository = studentRepository;
        this.emailService = emailService;
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Map<String, String> loginRequest) {
        String rollNo = loginRequest.get("rollNo");
        String password = loginRequest.get("password");

        return studentRepository.findByRollNo(rollNo)
                .map(student -> {
                    if (student.getPassword().equals(password)) {
                        return ResponseEntity.ok(student);
                    } else {
                        return ResponseEntity.status(401).body("Invalid credentials");
                    }
                })
                .orElse(ResponseEntity.status(404).body("User not found"));
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<?> forgotPassword(@RequestBody Map<String, String> request) {
        String rollNo = request.get("rollNo");
        return studentRepository.findByRollNo(rollNo)
                .map(student -> {
                    if (student.getEmail() == null || student.getEmail().isEmpty()) {
                        return ResponseEntity.badRequest().body("Email not registered for this student.");
                    }
                    String otp = String.format("%06d", new java.util.Random().nextInt(999999));
                    student.setOtp(otp);
                    student.setOtpExpiry(java.time.LocalDateTime.now().plusMinutes(10));
                    studentRepository.save(student);

                    emailService.sendOtp(student.getEmail(), otp);
                    return ResponseEntity.ok("OTP sent to registered email.");
                })
                .orElse(ResponseEntity.status(404).body("User not found"));
    }

    @PostMapping("/verify-otp")
    public ResponseEntity<?> verifyOtp(@RequestBody Map<String, String> request) {
        String rollNo = request.get("rollNo");
        String otp = request.get("otp");

        return studentRepository.findByRollNo(rollNo)
                .map(student -> {
                    if (student.getOtp() != null && student.getOtp().equals(otp) &&
                            student.getOtpExpiry().isAfter(java.time.LocalDateTime.now())) {
                        return ResponseEntity.ok("OTP verified.");
                    } else {
                        return ResponseEntity.badRequest().body("Invalid or expired OTP.");
                    }
                })
                .orElse(ResponseEntity.status(404).body("User not found"));
    }

    @PostMapping("/reset-password")
    public ResponseEntity<?> resetPassword(@RequestBody Map<String, String> request) {
        String rollNo = request.get("rollNo");
        String otp = request.get("otp");
        String newPassword = request.get("newPassword");

        return studentRepository.findByRollNo(rollNo)
                .map(student -> {
                    if (student.getOtp() != null && student.getOtp().equals(otp) &&
                            student.getOtpExpiry().isAfter(java.time.LocalDateTime.now())) {
                        student.setPassword(newPassword);
                        student.setOtp(null);
                        student.setOtpExpiry(null);
                        studentRepository.save(student);
                        return ResponseEntity.ok("Password reset successfully.");
                    } else {
                        return ResponseEntity.badRequest().body("Invalid or expired OTP.");
                    }
                })
                .orElse(ResponseEntity.status(404).body("User not found"));
    }
}
