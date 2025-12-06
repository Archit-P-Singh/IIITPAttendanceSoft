package com.iiitp.attendance.controller;

import com.iiitp.attendance.model.Student;
import com.iiitp.attendance.service.StudentService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/students")
public class StudentController {

    private final StudentService studentService;

    public StudentController(StudentService studentService) {
        this.studentService = studentService;
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
    public ResponseEntity<Student> regenerateQrCode(@PathVariable Integer id) {
        return studentService.getStudentById(id)
                .map(student -> {
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
