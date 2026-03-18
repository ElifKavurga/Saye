package com.elifkavurga.backend.map.risk;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;

public class DecayCalculator {

    private final Clock clock;

    public DecayCalculator(Clock clock) {
        this.clock = clock;
    }

    public double calculate(RiskCategory category, Instant createdAt) {
        if (category == null) {
            return 0.0;
        }
        if (createdAt == null) {
            return 0.0;
        }

        Duration age = Duration.between(createdAt, Instant.now(clock));
        if (age.isNegative()) {
            age = Duration.ZERO;
        }
        return category.decayFactor(age);
    }
}
