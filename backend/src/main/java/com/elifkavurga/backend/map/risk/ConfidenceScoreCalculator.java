package com.elifkavurga.backend.map.risk;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;

public class ConfidenceScoreCalculator {

    private final Clock clock;

    public ConfidenceScoreCalculator(Clock clock) {
        this.clock = clock;
    }

    public double calculate(ReportSignal reportSignal, int nearbyIndependentSignals, boolean contradictoryData, boolean longUnverifiedSingleton) {
        double storedConfidence = reportSignal.confidenceScore() == null ? 0.0 : reportSignal.confidenceScore();
        double confirmationBonus = Math.min(0.30, nearbyIndependentSignals * 0.10);
        double closeIndependentBonus = nearbyIndependentSignals > 0 ? 0.15 : 0.0;

        double proofBonus = hasMediaLikeSignal(reportSignal.description()) ? 0.10 : 0.0;
        double historyBonus = historicalAccuracyBonus(reportSignal.userId());

        double spamPenalty = 0.0;
        if (isRejected(reportSignal.status())) {
            spamPenalty += 0.20;
        }
        if (contradictoryData) {
            spamPenalty += 0.20;
        }
        if (longUnverifiedSingleton) {
            spamPenalty += 0.15;
        }

        double confidence = RiskCalculationConfig.CONFIDENCE_BASE
                + storedConfidence
                + confirmationBonus
                + closeIndependentBonus
                + proofBonus
                + historyBonus
                - spamPenalty;

        return clamp(confidence);
    }

    private double historicalAccuracyBonus(Long userId) {
        if (userId == null) {
            return 0.0;
        }
        long deterministicHash = Math.abs(userId) % 11L;
        return Math.min(0.15, 0.05 + (deterministicHash * 0.01));
    }

    private boolean hasMediaLikeSignal(String description) {
        return description != null && description.trim().length() > 90;
    }

    private boolean isRejected(String status) {
        return "REJECTED".equalsIgnoreCase(status);
    }

    private double clamp(double value) {
        return Math.max(RiskCalculationConfig.MIN_CONFIDENCE, Math.min(RiskCalculationConfig.MAX_CONFIDENCE, value));
    }

    public boolean isLongUnverifiedSingleton(ReportSignal signal) {
        return "PENDING".equalsIgnoreCase(signal.status())
                && signal.createdAt() != null
                && Duration.between(signal.createdAt(), Instant.now(clock)).toHours() >= 24;
    }
}
