package com.iiitp.attendance.controller;

import com.iiitp.attendance.model.Student;
import com.iiitp.attendance.model.OptOut;
import com.iiitp.attendance.model.MealType;
import com.iiitp.attendance.repository.OptOutRepository;
import com.iiitp.attendance.service.StudentService;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.data.redis.core.StringRedisTemplate;
import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalDateTime;

import java.util.List;

@RestController
@RequestMapping("/api/students")
public class StudentController {

    private final StudentService studentService;
    private final StringRedisTemplate redisTemplate;
    private final OptOutRepository optOutRepository;

    public StudentController(StudentService studentService, StringRedisTemplate redisTemplate, OptOutRepository optOutRepository) {
        this.studentService = studentService;
        this.redisTemplate = redisTemplate;
        this.optOutRepository = optOutRepository;
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

    @PostMapping("/{id}/opt-out")
    public ResponseEntity<?> optOut(@PathVariable Integer id,
                                    @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
                                    @RequestParam MealType mealType) {
        
        // Rule: Opt-out must be submitted by midnight of the day before the meal.
        if (LocalDate.now().isAfter(date.minusDays(1))) {
            return ResponseEntity.badRequest().body("You must opt-out at least one day in advance.");
        }

        return studentService.getStudentById(id).map(student -> {
            if (optOutRepository.findByStudentAndDateAndMealType(student, date, mealType).isPresent()) {
                return ResponseEntity.badRequest().body("Already opted out for this meal.");
            }
            OptOut optOut = new OptOut();
            optOut.setStudent(student);
            optOut.setDate(date);
            optOut.setMealType(mealType);
            optOutRepository.save(optOut);
            return ResponseEntity.ok("Successfully opted out of " + mealType + " on " + date);
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteStudent(@PathVariable Integer id) {
        studentService.deleteStudent(id);
        return ResponseEntity.noContent().build();
    }
}
