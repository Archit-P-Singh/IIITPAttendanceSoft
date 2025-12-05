package com.iiitp.attendance.repository;

import com.iiitp.attendance.model.Attendance;
import com.iiitp.attendance.model.Student;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;

public interface AttendanceRepository extends JpaRepository<Attendance, Integer> {
    List<Attendance> findByStudent(Student student);

    List<Attendance> findByDate(LocalDate date);

    List<Attendance> findByStudentAndDate(Student student, LocalDate date);

    long countByStudentAndDate(Student student, LocalDate date);
}
