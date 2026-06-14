package com.iiitp.attendance.service;

import com.iiitp.attendance.config.RabbitMQConfig;
import com.iiitp.attendance.model.ReportRequest;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
public class ReportMessageListener {

    private final ReportService reportService;
    // In a real scenario, you'd inject an EmailService here to send the generated report.

    public ReportMessageListener(ReportService reportService) {
        this.reportService = reportService;
    }

    @RabbitListener(queues = RabbitMQConfig.REPORT_QUEUE)
    public void processReportRequest(ReportRequest request) {
        System.out.println("Received report request for Year: " + request.getYear() + ", Month: " + request.getMonth());
        
        try {
            // Simulate heavy processing / PDF generation
            System.out.println("Starting heavy report generation for " + request.getEmailTo() + "...");
            Thread.sleep(5000); // Simulate delay
            
            Map<String, Object> reportData = reportService.getMonthlyFinancialReport(request.getYear(), request.getMonth());
            
            System.out.println("Report generated successfully!");
            System.out.println("Data: " + reportData);
            System.out.println("Email sent to: " + request.getEmailTo());

        } catch (InterruptedException e) {
            System.err.println("Report generation interrupted: " + e.getMessage());
            Thread.currentThread().interrupt();
        } catch (Exception e) {
            System.err.println("Failed to generate report: " + e.getMessage());
        }
    }
}
