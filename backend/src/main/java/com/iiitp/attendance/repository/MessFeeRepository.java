package com.iiitp.attendance.repository;

import com.iiitp.attendance.model.MessFee;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface MessFeeRepository extends JpaRepository<MessFee, Integer> {
    Optional<MessFee> findByYearAndMonth(Integer year, Integer month);
}
