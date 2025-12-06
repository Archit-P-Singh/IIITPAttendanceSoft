package com.iiitp.attendance.repository;

import com.iiitp.attendance.model.SystemConfig;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SystemConfigRepository extends JpaRepository<SystemConfig, String> {
}
