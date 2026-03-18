package com.elifkavurga.backend.map.risk;

import java.time.Duration;
import java.util.List;

public enum RiskCategory {
    SUC_GUVENLIK_IHLALI(85.0, 100.0, List.of(
        new DecayRule(Duration.ofHours(6), 1.00),
        new DecayRule(Duration.ofHours(24), 0.80),
        new DecayRule(Duration.ofHours(72), 0.50)
    )),
    DOGAL_AFET(80.0, 100.0, List.of(
            new DecayRule(Duration.ofHours(6), 1.00),
            new DecayRule(Duration.ofHours(24), 0.90),
            new DecayRule(Duration.ofHours(96), 0.70)
    )),
    TRAFIK_KAZA(60.0, 85.0, List.of(
            new DecayRule(Duration.ofHours(6), 1.00),
            new DecayRule(Duration.ofHours(24), 0.65),
            new DecayRule(Duration.ofHours(48), 0.30)
    )),
    ALTYAPI_FIZIKI_TEHLIKE(45.0, 70.0, List.of(
            new DecayRule(Duration.ofHours(6), 1.00),
            new DecayRule(Duration.ofHours(24), 0.85),
            new DecayRule(Duration.ofHours(72), 0.70)
    )),
    AYDINLATMA_SORUNU(25.0, 50.0, List.of(
            new DecayRule(Duration.ofHours(6), 1.00),
            new DecayRule(Duration.ofHours(24), 0.90),
            new DecayRule(Duration.ofHours(72), 0.80),
            new DecayRule(Duration.ofHours(336), 0.00)
    )),
    SUPHELI_DOGRULANMAMIS(20.0, 40.0, List.of(
            new DecayRule(Duration.ofHours(6), 0.70),
            new DecayRule(Duration.ofHours(24), 0.40),
            new DecayRule(Duration.ofHours(72), 0.20)
    ));

    private final double baseRisk;
    private final double cap;
    private final List<DecayRule> decayRules;

    RiskCategory(double baseRisk, double cap, List<DecayRule> decayRules) {
        this.baseRisk = baseRisk;
        this.cap = cap;
        this.decayRules = decayRules;
    }

    public double getBaseRisk() {
        return baseRisk;
    }

    public double getCap() {
        return cap;
    }

    public double decayFactor(Duration age) {
        long ageMinutes = Math.max(0L, age.toMinutes());
        long ageMinutesNormalized = ageMinutes;
        long ageThresholdMinutes;

        for (DecayRule decayRule : decayRules) {
            ageThresholdMinutes = decayRule.duration().toMinutes();
            if (ageMinutesNormalized <= ageThresholdMinutes) {
                return decayRule.factor();
            }
        }
        return 0.0;
    }

    public static RiskCategory fromLegacy(String rawCategory) {
        String normalized = rawCategory == null ? "" : rawCategory.trim().toUpperCase();
        return switch (normalized) {
            case "SECURITY" -> SUC_GUVENLIK_IHLALI;
            case "TRACKING", "NATURAL_DISASTER" -> DOGAL_AFET;
            case "TRAFFIC" -> TRAFIK_KAZA;
            case "INFRASTRUCTURE" -> ALTYAPI_FIZIKI_TEHLIKE;
            case "LIGHTING" -> AYDINLATMA_SORUNU;
            case "ANIMALS" -> SUPHELI_DOGRULANMAMIS;
            default -> SUPHELI_DOGRULANMAMIS;
        };
    }

    private record DecayRule(Duration duration, double factor) {
    }
}
