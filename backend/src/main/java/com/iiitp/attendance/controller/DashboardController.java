package com.iiitp.attendance.controller;

import com.iiitp.attendance.repository.StudentRepository;
import com.iiitp.attendance.service.ReportService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/dashboard")
public class DashboardController {

    private final ReportService reportService;
    private final StudentRepository studentRepository;

    public DashboardController(ReportService reportService, StudentRepository studentRepository) {
        this.reportService = reportService;
        this.studentRepository = studentRepository;
    }

    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getDashboardStats() {
        LocalDate now = LocalDate.now();
        LocalDate lastMonth = now.minusMonths(1);

        // Last Month Income (Net Fee Collected)
        Map<String, Object> financialReport = reportService.getMonthlyFinancialReport(lastMonth.getYear(),
                lastMonth.getMonthValue());
        double lastMonthIncome = (double) financialReport.get("netFeeCollected");

        // Days Functioned This Month (Assuming at least one attendance record implies
        // functioning)
        // For simplicity, we can count distinct dates in Attendance table for current
        // month
        // Or just return days passed so far if we assume it functions every day.
        // Let's use a method in ReportService to get actual attendance days count if
        // possible,
        // or just days elapsed for now as a placeholder if complex query needed.
        // Better: Add a method in ReportService to count distinct dates.
        long daysFunctioned = reportService.countFunctioningDays(now.getYear(), now.getMonthValue());

        // Total Students
        long totalStudents = studentRepository.count();

        Map<String, Object> stats = new HashMap<>();
        stats.put("lastMonthIncome", lastMonthIncome);
        stats.put("daysFunctioned", daysFunctioned);
        stats.put("totalStudents", totalStudents);

        return ResponseEntity.ok(stats);
    }
}
