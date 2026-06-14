package com.iiitp.attendance.repository;

import com.iiitp.attendance.model.MealType;
import com.iiitp.attendance.model.OptOut;
import com.iiitp.attendance.model.Student;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.Optional;

@Repository
public interface OptOutRepository extends JpaRepository<OptOut, Integer> {
    Optional<OptOut> findByStudentAndDateAndMealType(Student student, LocalDate date, MealType mealType);
    long countByDateAndMealType(LocalDate date, MealType mealType);
}
