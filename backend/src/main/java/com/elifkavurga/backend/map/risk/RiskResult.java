package com.elifkavurga.backend.map.risk;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public record RiskResult(
        double score,
        RiskLevel level,
        List<String> reasons,
        Map<String, Double> categoryBreakdown
) {

    public static RiskResult empty() {
        return new RiskResult(0.0, RiskLevel.LOW, List.of("NO_DATA"), Map.of());
    }

    public static RiskResult from(double score, List<String> reasons, Map<String, Double> breakdown) {
        double rounded = round(score);
        return new RiskResult(rounded, RiskLevel.fromScore(rounded), List.copyOf(reasons), new LinkedHashMap<>(breakdown));
    }

    private static double round(double value) {
        double bounded = Math.max(0.0, Math.min(100.0, value));
        return Math.round(bounded * 100.0) / 100.0;
    }
}
