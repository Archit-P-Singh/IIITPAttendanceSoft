package com.iiitp.attendance.repository;

import com.iiitp.attendance.model.Student;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface StudentRepository extends JpaRepository<Student, Integer> {
    Optional<Student> findByRollNo(String rollNo);
    Optional<Student> findByQrCode(String qrCode);
}
