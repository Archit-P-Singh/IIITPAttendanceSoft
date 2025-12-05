package com.iiitp.attendance.service;

import com.iiitp.attendance.model.Student;
import com.iiitp.attendance.repository.AttendanceRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDate;

@Service
public class RebateService {

    private final AttendanceRepository attendanceRepository;
    private static final double DAILY_MESS_FEE = 100.0;

    public RebateService(AttendanceRepository attendanceRepository) {
        this.attendanceRepository = attendanceRepository;
    }

    public double calculateDailyRebate(Student student, LocalDate date) {
        long mealCount = attendanceRepository.countByStudentAndDate(student, date);

        if (mealCount == 0) {
            return DAILY_MESS_FEE; // 100% rebate
        } else if (mealCount == 1) {
            return DAILY_MESS_FEE / 2; // 50% rebate
        } else {
            return 0.0; // No rebate
        }
    }
}
