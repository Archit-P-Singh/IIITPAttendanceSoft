package com.iiitp.attendance.testing;

import com.iiitp.attendance.model.*;
import com.iiitp.attendance.repository.AttendanceRepository;
import com.iiitp.attendance.repository.StudentRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

@Component
@ConditionalOnProperty(name = "app.seed-data", havingValue = "true")
public class DataSeeder implements CommandLineRunner {

    private final StudentRepository studentRepository;
    private final AttendanceRepository attendanceRepository;

    public DataSeeder(StudentRepository studentRepository, AttendanceRepository attendanceRepository) {
        this.studentRepository = studentRepository;
        this.attendanceRepository = attendanceRepository;
    }

    @Override
    public void run(String... args) throws Exception {
        System.out.println("====== STARTING DATA SEEDER ======");

        if (studentRepository.count() > 0) {
            System.out.println("Data already exists. Wiping old data...");
            attendanceRepository.deleteAll();
            studentRepository.deleteAll();
        }

        Random random = new Random();
        List<Student> students = new ArrayList<>();

        // Create Admin
        Student admin = new Student();
        admin.setName("Admin User");
        admin.setRollNo("ADMIN001");
        admin.setQrCode("QR_ADMIN_001");
        admin.setPassword("admin123");
        admin.setRole(Role.ADMIN);
        admin.setEmail("admin@iiitp.ac.in");
        studentRepository.save(admin);

        // Create Manager
        Student manager = new Student();
        manager.setName("Mess Manager");
        manager.setRollNo("MANAGER001");
        manager.setQrCode("QR_MANAGER_001");
        manager.setPassword("manager123");
        manager.setRole(Role.MESS_MANAGER);
        manager.setEmail("manager@iiitp.ac.in");
        studentRepository.save(manager);

        // Create 50 Students
        for (int i = 1; i <= 50; i++) {
            Student s = new Student();
            s.setName("Student " + i);
            s.setRollNo("1123150" + String.format("%02d", i));
            s.setQrCode("QR_" + s.getRollNo());
            s.setPassword("password123");
            s.setRole(Role.STUDENT);
            s.setEmail("student" + i + "@iiitp.ac.in");
            s.setDepartment("CSE");
            s.setYear(4);
            s.setSemester(8);
            s.setHostel("Boys Hostel A");
            students.add(s);
        }
        studentRepository.saveAll(students);
        System.out.println("Created 50 Mock Students.");

        // Create Attendance for the last 30 days
        LocalDate today = LocalDate.now();
        List<Attendance> attendances = new ArrayList<>();

        for (Student s : students) {
            for (int i = 1; i <= 30; i++) {
                LocalDate date = today.minusDays(i);
                
                for (MealType meal : MealType.values()) {
                    // 85% probability of being present
                    boolean isPresent = random.nextInt(100) < 85;

                    Attendance attendance = new Attendance();
                    attendance.setStudent(s);
                    attendance.setDate(date);
                    attendance.setMealType(meal);
                    attendance.setPresent(isPresent);
                    attendances.add(attendance);
                }
            }
        }
        
        attendanceRepository.saveAll(attendances);
        System.out.println("Created " + attendances.size() + " Attendance Records (Simulating 30 days).");
        
        System.out.println("====== DATA SEEDING COMPLETE ======");
    }
}
