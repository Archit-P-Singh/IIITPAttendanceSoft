package com.iiitp.attendance.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "students")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Student {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer studentId;

    @Column(nullable = false)
    private String name;

    @Column(unique = true, nullable = false)
    private String rollNo;

    @Column(unique = true, nullable = false)
    private String qrCode;

    private String department;

    @Column(nullable = false)
    private String password;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Role role;

    @Column(unique = true)
    private String email;

    private String otp;
    private java.time.LocalDateTime otpExpiry;

    private Integer year;
    private Integer semester;
    private String hostel;
}
