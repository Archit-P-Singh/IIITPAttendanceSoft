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
}
