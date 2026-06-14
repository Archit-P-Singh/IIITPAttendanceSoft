package com.iiitp.attendance.controller;

import com.iiitp.attendance.model.MealType;
import com.iiitp.attendance.model.Role;
import com.iiitp.attendance.repository.OptOutRepository;
import com.iiitp.attendance.repository.StudentRepository;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/manager/prediction")
public class PredictionController {

    private final OptOutRepository optOutRepository;
    private final StudentRepository studentRepository;

    public PredictionController(OptOutRepository optOutRepository, StudentRepository studentRepository) {
        this.optOutRepository = optOutRepository;
        this.studentRepository = studentRepository;
    }

    @GetMapping
    public ResponseEntity<Map<String, Object>> getPrediction(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
            @RequestParam MealType mealType) {

        // Total active students
        long totalStudents = studentRepository.findAll().stream()
                .filter(s -> s.getRole() == Role.STUDENT)
                .count();

        // Total opt-outs for this specific date and meal
        long optOuts = optOutRepository.countByDateAndMealType(date, mealType);

        long predictedHeadcount = totalStudents - optOuts;

        Map<String, Object> response = new HashMap<>();
        response.put("date", date);
        response.put("mealType", mealType);
        response.put("totalStudents", totalStudents);
        response.put("optOuts", optOuts);
        response.put("predictedHeadcount", predictedHeadcount);

        return ResponseEntity.ok(response);
    }
}
