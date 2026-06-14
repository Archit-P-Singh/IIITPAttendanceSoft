package com.iiitp.attendance.controller;

import com.iiitp.attendance.service.ReportService;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import com.iiitp.attendance.config.RabbitMQConfig;
import com.iiitp.attendance.model.ReportRequest;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.Map;

@RestController
@RequestMapping("/api/reports")
public class ReportController {

    private final ReportService reportService;
    private final RabbitTemplate rabbitTemplate;

    public ReportController(ReportService reportService, RabbitTemplate rabbitTemplate) {
        this.reportService = reportService;
        this.rabbitTemplate = rabbitTemplate;
    }

    @GetMapping("/financial/monthly")
    public ResponseEntity<Map<String, Object>> getMonthlyFinancialReport(
            @RequestParam int year,
            @RequestParam int month) {
        return ResponseEntity.ok(reportService.getMonthlyFinancialReport(year, month));
    }

    @PostMapping("/financial/monthly/async")
    public ResponseEntity<String> generateMonthlyFinancialReportAsync(
            @RequestBody ReportRequest request) {
        
        // Push task to RabbitMQ Queue
        rabbitTemplate.convertAndSend(RabbitMQConfig.REPORT_EXCHANGE, RabbitMQConfig.REPORT_ROUTING_KEY, request);
        
        return ResponseEntity.accepted().body("Report generation has been queued successfully. You will receive an email shortly.");
    }

    @GetMapping("/student/{studentId}/monthly")
    public ResponseEntity<Map<String, Object>> getStudentMonthlyReport(
            @PathVariable Integer studentId,
            @RequestParam int year,
            @RequestParam int month) {
        return ResponseEntity.ok(reportService.getStudentMonthlyReport(studentId, year, month));
    }

    @GetMapping("/attendance/daily")
    public ResponseEntity<Map<String, Long>> getDailyAttendanceStats(@RequestParam String date) {
        LocalDate localDate = LocalDate.parse(date);
        return ResponseEntity.ok(reportService.getDailyAttendanceStats(localDate));
    }

    @GetMapping("/financial/daily-chart")
    public ResponseEntity<Map<String, Double>> getDailyFinancialChart(@RequestParam int year, @RequestParam int month) {
        // For simplicity, we can reuse getDailyAttendanceStats for each day and
        // multiply by fee
        // But let's ask ReportService for this specific data structure
        return ResponseEntity.ok(reportService.getDailyFinancialChart(year, month));
    }

    @GetMapping("/stats/meal-wise")
    public ResponseEntity<Map<String, Long>> getMealWiseStats(@RequestParam int year, @RequestParam int month) {
        return ResponseEntity.ok(reportService.getMealWiseStats(year, month));
    }
}
