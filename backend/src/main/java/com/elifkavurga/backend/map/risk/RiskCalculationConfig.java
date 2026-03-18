package com.elifkavurga.backend.map.risk;

import java.time.Duration;
import java.util.List;

public final class RiskCalculationConfig {

    public static final double MIN_CONFIDENCE = 0.20;
    public static final double MAX_CONFIDENCE = 1.0;
    public static final double CONFIDENCE_BASE = 0.50;
    public static final double CRITICAL_SINGLE_REPORT_TRIGGER = 0.30;

    public static final Duration DUPLICATE_WINDOW = Duration.ofMinutes(10);
    public static final double DUPLICATE_REGION_DISTANCE_METERS = 250.0;
    public static final double CRITICAL_REGION_DISTANCE_METERS = 250.0;
    public static final Duration RISK_LOOKBACK = Duration.ofDays(14);
    public static final Duration RECENT_VERIFICATION_WINDOW = Duration.ofHours(24);

    public static final List<Double> DIMINISHING_WEIGHTS = List.of(1.0, 0.60, 0.35, 0.20);
    public static final double REPEATING_REPORT_MIN_WEIGHT = 0.10;

    public static final double PROXIMITY_NEAR_METER = 100.0;
    public static final double PROXIMITY_MID_METER = 250.0;
    public static final double PROXIMITY_FAR_METER = 400.0;
    public static final double PROXIMITY_NEAR_WEIGHT = 1.0;
    public static final double PROXIMITY_MID_WEIGHT = 0.70;
    public static final double PROXIMITY_FAR_WEIGHT = 0.40;
    public static final double PROXIMITY_DISTANT_WEIGHT = 0.20;

    public static final int CRITICAL_DOMINANCE_CRIME_CONFIDENCE_COUNT = 1;
    public static final double CRITICAL_DOMINANCE_CONFIDENCE_MIN = 0.55;
    public static final int CRITICAL_DOMINANCE_CRIME_CONFIDENCE_DOUBLE_COUNT = 2;
    public static final double CRITICAL_DOMINANCE_CONFIDENCE_DOUBLE_MIN = 0.80;

    private RiskCalculationConfig() {
    }
}
