package com.iiitp.attendance.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.io.Serializable;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ReportRequest implements Serializable {
    private int year;
    private int month;
    private String emailTo;
}
