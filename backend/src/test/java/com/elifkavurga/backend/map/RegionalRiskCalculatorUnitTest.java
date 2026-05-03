package com.elifkavurga.backend.map;

import com.elifkavurga.backend.map.risk.RegionalRiskCalculator;
import com.elifkavurga.backend.map.risk.RiskLevel;
import com.elifkavurga.backend.map.risk.RiskResult;
import com.elifkavurga.backend.report.repository.projection.NearbyReportProjection;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.time.Clock;
import java.time.Instant;
import java.time.ZoneOffset;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

class RegionalRiskCalculatorUnitTest {

    private static final String REVIEWING = "REVIEWING";
    private static final String REJECTED = "REJECTED";
    private static final String PENDING = "PENDING";
    private RegionalRiskCalculator calculator;
    private Clock fixedClock;

    @BeforeEach
    void setUp() {
        fixedClock = Clock.fixed(Instant.parse("2026-03-02T00:00:00Z"), ZoneOffset.UTC);
        calculator = new RegionalRiskCalculator(fixedClock);
    }

    @Test
    void oneCrimeReportShouldProduceHighRisk() {
        RiskResult result = calculator.calculate(List.of(
                report("SECURITY", 1, 1L, 1, 50, REVIEWING)
        ));

        assertThat(result.level()).isIn(RiskLevel.CRITICAL, RiskLevel.HIGH);
        assertThat(result.score()).isGreaterThan(60);
    }

    @Test
    void duplicateReportFromSameUserInTenMinutesIsDeduplicated() {
        Instant now = fixedClock.instant();
        RiskResult result = calculator.calculate(List.of(
                report("SECURITY", 1.0, 1L, 0, 50, REVIEWING),
                reportWithCreatedAt("SECURITY", 1.0, 1L, 60, REVIEWING, now.minusSeconds(5 * 60))
        ));

        assertThat(result.score()).isBetween(80d, 86d);
        assertThat(result.level()).isIn(RiskLevel.HIGH, RiskLevel.CRITICAL);
    }

    @Test
    void twoIndependentHighConfidenceCrimeReportsShouldMakeCritical() {
        RiskResult result = calculator.calculate(List.of(
                report("SECURITY", 1.0, 1L, 1, 20, REVIEWING),
                report("SECURITY", 1.0, 2L, 1, 40, REVIEWING)
        ));

        assertThat(result.level()).isEqualTo(RiskLevel.CRITICAL);
        assertThat(result.score()).isGreaterThanOrEqualTo(80);
    }

    @Test
    void threeLightingReportsShouldProduceAround4875() {
        RiskResult result = calculator.calculate(List.of(
                report("LIGHTING", 1.0, 1L, 1, 10, REVIEWING),
                report("LIGHTING", 1.0, 2L, 1, 20, REVIEWING),
                report("LIGHTING", 1.0, 3L, 1, 30, REVIEWING)
        ));

        assertThat(result.score()).isBetween(48d, 49d);
        assertThat(result.level()).isEqualTo(RiskLevel.MEDIUM);
    }

    @Test
    void twoInfrastructureReportsShouldStayBelowHighWithoutCrime() {
        RiskResult result = calculator.calculate(List.of(
                report("INFRASTRUCTURE", 1.0, 1L, 1, 20, REVIEWING),
                report("INFRASTRUCTURE", 1.0, 2L, 1, 30, REVIEWING)
        ));

        assertThat(result.score()).isEqualTo(59.99);
        assertThat(result.level()).isEqualTo(RiskLevel.MEDIUM);
    }

    @Test
    void expiredDecayRecordsShouldNotBeIncluded() {
        RiskResult result = calculator.calculate(List.of(
                report("SECURITY", 1.0, 1L, 80, 20, REVIEWING)
        ));

        assertThat(result.score()).isEqualTo(0);
        assertThat(result.level()).isEqualTo(RiskLevel.LOW);
    }

    @Test
    void confidenceShouldRespectLowerClamp() {
        RiskResult result = calculator.calculate(List.of(
                report("SECURITY", -5.0, null, 1, 20, PENDING)
        ));

        assertThat(result.score()).isEqualTo(17.0);
        assertThat(result.level()).isEqualTo(RiskLevel.LOW);
    }

    @Test
    void confidenceShouldRespectUpperClamp() {
        RiskResult result = calculator.calculate(List.of(
                report("SECURITY", 10.0, 1L, 1, 20, REVIEWING)
        ));

        assertThat(result.score()).isEqualTo(85.0);
        assertThat(result.level()).isIn(RiskLevel.CRITICAL, RiskLevel.HIGH);
    }

    @Test
    void proximityShouldDecreaseRiskWithDistance() {
        RiskResult result = calculator.calculate(List.of(
                report("INFRASTRUCTURE", 1.0, 1L, 1, 20, REVIEWING),
                report("INFRASTRUCTURE", 1.0, 2L, 1, 450, REVIEWING)
        ));

        assertThat(result.score()).isEqualTo(49.0);
        assertThat(result.level()).isEqualTo(RiskLevel.MEDIUM);
    }

    @Test
    void lowConfidenceSpamAloneShouldNotBeCritical() {
        RiskResult result = calculator.calculate(List.of(
                report("SECURITY", 0.0, 1L, 40, 20, REJECTED)
        ));

        assertThat(result.level()).isIn(RiskLevel.LOW, RiskLevel.MEDIUM);
        assertThat(result.score()).isLessThan(80);
    }

    private NearbyReportProjection report(
            String category,
            double confidence,
            Long userId,
            int ageHours,
            double distanceMeters,
            String status
    ) {
        return reportWithCreatedAt(category, confidence, userId, distanceMeters, status, fixedClock.instant().minusSeconds(ageHours * 3600L));
    }

    private NearbyReportProjection reportWithCreatedAt(
            String category,
            double confidence,
            Long userId,
            double distanceMeters,
            String status,
            Instant createdAt
    ) {
        return new NearbyReportProjection() {
            @Override
            public Long getId() {
                return 1L;
            }

            @Override
            public Long getUserId() {
                return userId;
            }

            @Override
            public String getCategory() {
                return category;
            }

            @Override
            public String getDescription() {
                return "risk test";
            }

            @Override
            public Double getLatitude() {
                return 0.0;
            }

            @Override
            public Double getLongitude() {
                return 0.0;
            }

            @Override
            public Instant getCreatedAt() {
                return createdAt;
            }

            @Override
            public String getStatus() {
                return status;
            }

            @Override
            public Double getConfidenceScore() {
                return confidence;
            }

            @Override
            public Double getDistanceMeters() {
                return distanceMeters;
            }
        };
    } 
}
