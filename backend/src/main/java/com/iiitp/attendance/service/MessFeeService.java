package com.iiitp.attendance.service;

import com.iiitp.attendance.model.MessFee;
import com.iiitp.attendance.repository.MessFeeRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDate;

@Service
public class MessFeeService {

    private final MessFeeRepository messFeeRepository;
    private static final double DEFAULT_FEE = 100.0;

    public MessFeeService(MessFeeRepository messFeeRepository) {
        this.messFeeRepository = messFeeRepository;
    }

    public MessFee setFee(int year, int month, double amount) {
        // Constraint: Can only update in the first 5 days of the month
        LocalDate now = LocalDate.now();
        if (now.getYear() == year && now.getMonthValue() == month) {
            if (now.getDayOfMonth() > 5) {
                throw new RuntimeException("Mess fee can only be updated in the first 5 days of the month.");
            }
        }

        MessFee messFee = messFeeRepository.findByYearAndMonth(year, month)
                .orElse(new MessFee());

        if (messFee.getId() == null) {
            messFee.setYear(year);
            messFee.setMonth(month);
        }

        messFee.setAmount(amount);
        return messFeeRepository.save(messFee);
    }

    public double getFee(int year, int month) {
        return messFeeRepository.findByYearAndMonth(year, month)
                .map(MessFee::getAmount)
                .orElse(DEFAULT_FEE);
    }
}
