package com.iiitp.attendance.controller;

import com.iiitp.attendance.service.ReportService;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.Map;

@RestController
@RequestMapping("/api/reports")
public class ReportController {

    private final ReportService reportService;

    public ReportController(ReportService reportService) {
        this.reportService = reportService;
    }

    @GetMapping("/financial/monthly")
    public ResponseEntity<Map<String, Object>> getMonthlyFinancialReport(
            @RequestParam int year,
            @RequestParam int month) {
        return ResponseEntity.ok(reportService.getMonthlyFinancialReport(year, month));
    }

    @GetMapping("/student/{studentId}/monthly")
    public ResponseEntity<Map<String, Object>> getStudentMonthlyReport(
            @PathVariable Integer studentId,
            @RequestParam int year,
            @RequestParam int month) {
        return ResponseEntity.ok(reportService.getStudentMonthlyReport(studentId, year, month));
    }

    @GetMapping("/attendance/daily")
    public ResponseEntity<Map<String, Long>> getDailyAttendanceStats(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        return ResponseEntity.ok(reportService.getDailyAttendanceStats(date));
    }
}
