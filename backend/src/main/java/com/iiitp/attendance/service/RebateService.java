package com.iiitp.attendance.service;

import com.iiitp.attendance.model.Student;
import com.iiitp.attendance.repository.AttendanceRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDate;

@Service
public class RebateService {

    private final AttendanceRepository attendanceRepository;
    private final MessFeeService messFeeService;

    public RebateService(AttendanceRepository attendanceRepository, MessFeeService messFeeService) {
        this.attendanceRepository = attendanceRepository;
        this.messFeeService = messFeeService;
    }

    public double calculateDailyRebate(Student student, LocalDate date) {
        long mealCount = attendanceRepository.countByStudentAndDate(student, date);
        double dailyFee = messFeeService.getFee(date.getYear(), date.getMonthValue());

        if (mealCount == 0) {
            return dailyFee; // 100% rebate
        } else if (mealCount == 1) {
            return dailyFee / 2; // 50% rebate
        } else {
            return 0.0; // No rebate
        }
    }
}
