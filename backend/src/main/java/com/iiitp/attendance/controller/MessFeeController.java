package com.iiitp.attendance.controller;

import com.iiitp.attendance.model.MessFee;
import com.iiitp.attendance.service.MessFeeService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/mess-fee")
public class MessFeeController {

    private final MessFeeService messFeeService;

    public MessFeeController(MessFeeService messFeeService) {
        this.messFeeService = messFeeService;
    }

    @PostMapping
    public ResponseEntity<?> setMessFee(@RequestBody Map<String, Object> request) {
        try {
            int year = (int) request.get("year");
            int month = (int) request.get("month");
            // Handle double or integer input for amount
            double amount = Double.parseDouble(request.get("amount").toString());

            MessFee messFee = messFeeService.setFee(year, month, amount);
            return ResponseEntity.ok(messFee);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @GetMapping
    public ResponseEntity<Double> getMessFee(@RequestParam int year, @RequestParam int month) {
        return ResponseEntity.ok(messFeeService.getFee(year, month));
    }
}
