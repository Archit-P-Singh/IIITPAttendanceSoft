package com.iiitp.attendance.model;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Data
@NoArgsConstructor
public class SystemConfig {
    @Id
    private String configKey; // e.g., "ALLOW_FEE_UPDATE"
    private String configValue; // e.g., "true" or "false"

    public SystemConfig(String configKey, String configValue) {
        this.configKey = configKey;
        this.configValue = configValue;
    }
}
