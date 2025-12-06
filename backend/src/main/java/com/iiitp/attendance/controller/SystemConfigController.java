package com.iiitp.attendance.controller;

import com.iiitp.attendance.model.SystemConfig;
import com.iiitp.attendance.repository.SystemConfigRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/config")
public class SystemConfigController {

    private final SystemConfigRepository systemConfigRepository;

    public SystemConfigController(SystemConfigRepository systemConfigRepository) {
        this.systemConfigRepository = systemConfigRepository;
    }

    @GetMapping("/{key}")
    public ResponseEntity<String> getConfig(@PathVariable String key) {
        return systemConfigRepository.findById(key)
                .map(SystemConfig::getConfigValue)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.ok("false")); // Default to false if not set
    }

    @PostMapping
    public ResponseEntity<SystemConfig> setConfig(@RequestBody Map<String, String> request) {
        String key = request.get("key");
        String value = request.get("value");
        SystemConfig config = new SystemConfig(key, value);
        return ResponseEntity.ok(systemConfigRepository.save(config));
    }
}
