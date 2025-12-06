package com.iiitp.attendance.service;

import com.iiitp.attendance.model.Attendance;
import com.iiitp.attendance.model.MealType;
import com.iiitp.attendance.model.Student;
import com.iiitp.attendance.repository.AttendanceRepository;
import com.iiitp.attendance.repository.StudentRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.YearMonth;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class ReportService {

    private final AttendanceRepository attendanceRepository;
    private final StudentRepository studentRepository;
    private final RebateService rebateService;
    private final MessFeeService messFeeService;

    public ReportService(AttendanceRepository attendanceRepository, StudentRepository studentRepository,
            RebateService rebateService, MessFeeService messFeeService) {
        this.attendanceRepository = attendanceRepository;
        this.studentRepository = studentRepository;
        this.rebateService = rebateService;
        this.messFeeService = messFeeService;
    }

    public Map<String, Object> getMonthlyFinancialReport(int year, int month) {
        YearMonth yearMonth = YearMonth.of(year, month);
        int daysInMonth = yearMonth.lengthOfMonth();

        // Use dynamic fee for the month (assuming it's set for the whole month)
        // In a real scenario, fee might change daily, but here we take the monthly
        // config
        double dailyFee = messFeeService.getFee(year, month); // Fallback
        try {
            // We can't easily inject MessFeeService here without circular dependency if not
            // careful
            // But ReportService depends on RebateService, not the other way around.
            // Let's just use 100.0 for now or better, inject MessFeeService.
        } catch (Exception e) {
        }

        // Wait, I should inject MessFeeService into ReportService too.

        double totalExpectedFee = 0;
        double totalRebate = 0;

        List<Student> students = studentRepository.findAll();

        for (Student student : students) {
            if ("STUDENT".equals(student.getRole().name())) {
                totalExpectedFee += daysInMonth * dailyFee;

                for (int day = 1; day <= daysInMonth; day++) {
                    LocalDate date = LocalDate.of(year, month, day);
                    if (date.isBefore(LocalDate.now().plusDays(1))) { // Only calculate up to today
                        totalRebate += rebateService.calculateDailyRebate(student, date);
                    }
                }
            }
        }

        Map<String, Object> report = new HashMap<>();
        report.put("year", year);
        report.put("month", month);
        report.put("totalStudents", students.stream().filter(s -> "STUDENT".equals(s.getRole().name())).count());
        report.put("totalExpectedFee", totalExpectedFee);
        report.put("totalRebate", totalRebate);
        report.put("netFeeCollected", totalExpectedFee - totalRebate);

        return report;
    }

    public Map<String, Object> getStudentMonthlyReport(Integer studentId, int year, int month) {
        Student student = studentRepository.findById(studentId)
                .orElseThrow(() -> new RuntimeException("Student not found"));

        YearMonth yearMonth = YearMonth.of(year, month);
        int daysInMonth = yearMonth.lengthOfMonth();
        double totalRebate = 0;
        int totalMeals = 0;

        for (int day = 1; day <= daysInMonth; day++) {
            LocalDate date = LocalDate.of(year, month, day);
            if (date.isBefore(LocalDate.now().plusDays(1))) {
                totalRebate += rebateService.calculateDailyRebate(student, date);
                totalMeals += attendanceRepository.countByStudentAndDate(student, date);
            }
        }

        Map<String, Object> report = new HashMap<>();
        report.put("studentName", student.getName());
        report.put("rollNo", student.getRollNo());
        report.put("month", month);
        report.put("totalMealsConsumed", totalMeals);
        report.put("totalRebateEarned", totalRebate);

        return report;
    }

    public Map<String, Long> getDailyAttendanceStats(LocalDate date) {
        List<Attendance> attendanceList = attendanceRepository.findByDate(date);

        Map<String, Long> stats = new HashMap<>();
        stats.put("BREAKFAST", attendanceList.stream().filter(a -> a.getMealType() == MealType.BREAKFAST).count());
        stats.put("LUNCH", attendanceList.stream().filter(a -> a.getMealType() == MealType.LUNCH).count());
        stats.put("TEA", attendanceList.stream().filter(a -> a.getMealType() == MealType.TEA).count());
        stats.put("DINNER", attendanceList.stream().filter(a -> a.getMealType() == MealType.DINNER).count());

        return stats;
    }
}
