package com.elifkavurga.backend.map.risk;

public enum RiskLevel {
    LOW,
    MEDIUM,
    HIGH,
    CRITICAL;

    public static RiskLevel fromScore(double score) {
        if (score >= 80.0) {
            return CRITICAL;
        }
        if (score >= 60.0) {
            return HIGH;
        }
        if (score >= 30.0) {
            return MEDIUM;
        }
        return LOW;
    }
}
