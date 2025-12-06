package com.iiitp.attendance.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "mess_fees")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class MessFee {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(nullable = false)
    private Integer year;

    @Column(nullable = false)
    private Integer month;

    @Column(nullable = false)
    private Double amount;
}
