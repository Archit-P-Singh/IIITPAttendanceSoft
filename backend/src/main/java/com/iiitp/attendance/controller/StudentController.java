package com.iiitp.attendance.controller;

import com.iiitp.attendance.model.Student;
import com.iiitp.attendance.service.StudentService;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.data.redis.core.StringRedisTemplate;
import java.time.Duration;

import java.util.List;

@RestController
@RequestMapping("/api/students")
public class StudentController {

    private final StudentService studentService;
    private final StringRedisTemplate redisTemplate;

    public StudentController(StudentService studentService, StringRedisTemplate redisTemplate) {
        this.studentService = studentService;
        this.redisTemplate = redisTemplate;
    }

    @PostMapping
    public ResponseEntity<Student> addStudent(@RequestBody Student student) {
        return ResponseEntity.ok(studentService.saveStudent(student));
    }

    @GetMapping
    public ResponseEntity<List<Student>> getAllStudents() {
        return ResponseEntity.ok(studentService.getAllStudents());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Student> getStudentById(@PathVariable Integer id) {
        return studentService.getStudentById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<Student> updateStudent(@PathVariable Integer id, @RequestBody Student studentDetails) {
        return studentService.getStudentById(id)
                .map(student -> {
                    student.setName(studentDetails.getName());
                    student.setDepartment(studentDetails.getDepartment());
                    if (studentDetails.getPassword() != null && !studentDetails.getPassword().isEmpty()) {
                        student.setPassword(studentDetails.getPassword());
                    }
                    if (studentDetails.getEmail() != null && !studentDetails.getEmail().isEmpty()) {
                        student.setEmail(studentDetails.getEmail());
                    }
                    return ResponseEntity.ok(studentService.saveStudent(student));
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping("/{id}/regenerate-qr")
    public ResponseEntity<?> regenerateQrCode(@PathVariable Integer id) {
        String key = "rate_limit:qr:" + id;
        Long count = redisTemplate.opsForValue().increment(key);
        if (count != null && count == 1) {
            redisTemplate.expire(key, Duration.ofMinutes(1));
        }
        if (count != null && count > 5) {
            return ResponseEntity.status(HttpStatus.TOO_MANY_REQUESTS)
                    .body("Rate limit exceeded. Maximum 5 QR regenerations allowed per minute. Please try again later.");
        }

        return studentService.getStudentById(id)
                .<ResponseEntity<?>>map(student -> {
                    student.setQrCode("QR_" + student.getRollNo() + "_" + System.currentTimeMillis());
                    return ResponseEntity.ok(studentService.saveStudent(student));
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteStudent(@PathVariable Integer id) {
        studentService.deleteStudent(id);
        return ResponseEntity.noContent().build();
    }
}
