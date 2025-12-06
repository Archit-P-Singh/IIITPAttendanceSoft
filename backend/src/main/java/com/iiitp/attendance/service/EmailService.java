package com.iiitp.attendance.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
public class EmailService {

    private final JavaMailSender javaMailSender;

    @Value("${spring.mail.username:test@example.com}")
    private String senderEmail;

    public EmailService(JavaMailSender javaMailSender) {
        this.javaMailSender = javaMailSender;
    }

    public void sendOtp(String toEmail, String otp) {
        // For development/demo without real SMTP credentials, we log the OTP
        System.out.println("========================================");
        System.out.println("SENDING OTP TO: " + toEmail);
        System.out.println("OTP: " + otp);
        System.out.println("========================================");

        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setFrom(senderEmail);
            message.setTo(toEmail);
            message.setSubject("Password Reset OTP - IIITP Mess Attendance");
            message.setText("Your OTP for password reset is: " + otp + "\nThis OTP is valid for 10 minutes.");
            javaMailSender.send(message);
        } catch (Exception e) {
            System.out.println("Failed to send email (expected if no SMTP config): " + e.getMessage());
        }
    }
}
