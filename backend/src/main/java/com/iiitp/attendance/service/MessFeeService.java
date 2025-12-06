package com.iiitp.attendance.service;

import com.iiitp.attendance.model.MessFee;
import com.iiitp.attendance.repository.MessFeeRepository;
import com.iiitp.attendance.repository.SystemConfigRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDate;

@Service
public class MessFeeService {

    private final MessFeeRepository messFeeRepository;
    private final SystemConfigRepository systemConfigRepository;
    private static final double DEFAULT_FEE = 100.0;

    public MessFeeService(MessFeeRepository messFeeRepository, SystemConfigRepository systemConfigRepository) {
        this.messFeeRepository = messFeeRepository;
        this.systemConfigRepository = systemConfigRepository;
    }

    public MessFee setFee(int year, int month, double amount) {
        // Check System Config first
        boolean allowUpdate = systemConfigRepository.findById("ALLOW_FEE_UPDATE")
                .map(config -> Boolean.parseBoolean(config.getConfigValue()))
                .orElse(false);

        // If config allows, skip date check. Else, enforce 5-day rule.
        if (!allowUpdate) {
            LocalDate now = LocalDate.now();
            if (now.getDayOfMonth() > 5) {
                throw new RuntimeException(
                        "Mess fee can only be updated in the first 5 days of the month, or if enabled by Admin.");
            }
        }

        MessFee messFee = messFeeRepository.findByYearAndMonth(year, month)
                .orElse(new MessFee());
        messFee.setYear(year);
        messFee.setMonth(month);
        messFee.setAmount(amount);
        return messFeeRepository.save(messFee);
    }

    public double getFee(int year, int month) {
        return messFeeRepository.findByYearAndMonth(year, month)
                .map(MessFee::getAmount)
                .orElse(DEFAULT_FEE);
    }
}
