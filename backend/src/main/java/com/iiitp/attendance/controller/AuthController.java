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

    public AuthController(StudentRepository studentRepository) {
        this.studentRepository = studentRepository;
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
}
