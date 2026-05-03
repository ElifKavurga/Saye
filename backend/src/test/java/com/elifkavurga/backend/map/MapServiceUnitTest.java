package com.elifkavurga.backend.map;

import com.elifkavurga.backend.map.risk.RegionalRiskCalculator;
import com.elifkavurga.backend.map.service.MapRiskProcessor;
import com.elifkavurga.backend.map.service.RiskCircle;
import com.elifkavurga.backend.map.service.RiskCircleBuilder;
import com.elifkavurga.backend.map.service.RiskCluster;
import com.elifkavurga.backend.map.service.RiskClusterService;
import com.elifkavurga.backend.map.service.MapServiceImpl;
import com.elifkavurga.backend.map.dto.RiskResponse;
import com.elifkavurga.backend.report.repository.ReportRepository;
import com.elifkavurga.backend.report.repository.projection.NearbyReportProjection;
import org.locationtech.jts.geom.Point;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;

import java.time.Clock;
import java.time.Instant;
import java.time.ZoneOffset;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyDouble;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class MapServiceUnitTest {

    private ReportRepository repo;
    private MapServiceImpl service;
    private Clock fixedClock;

    @BeforeEach
    void setup() {
        repo = Mockito.mock(ReportRepository.class);
        fixedClock = Clock.fixed(Instant.parse("2026-03-02T00:00:00Z"), ZoneOffset.UTC);
        RegionalRiskCalculator regionalRiskCalculator = new RegionalRiskCalculator(fixedClock);
        MapRiskProcessor mapRiskProcessor = new MapRiskProcessor(
                new RiskClusterService(),
                new RiskCircleBuilder(regionalRiskCalculator)
        );
        service = new MapServiceImpl(repo, mapRiskProcessor, fixedClock);
    }

    @Test
    void computeRiskDeterministic() {
        NearbyReportProjection r1 = nearbyReport("SECURITY", 1.0, 1L, 0.0);
        NearbyReportProjection r2 = nearbyReport("LIGHTING", 0.8, 10L, 500.0);

        when(repo.findActiveNearbyReports(any(Point.class), anyDouble(), any(Instant.class)))
                .thenReturn(List.of(r1, r2));

        RiskResponse first = service.computeRisk(0.0, 0.0);
        RiskResponse second = service.computeRisk(0.0, 0.0);

        assertThat(first).isEqualTo(second);
        assertThat(first.getLevel()).isIn("LOW", "MEDIUM", "HIGH", "CRITICAL");
        assertThat(first.getScore()).isGreaterThan(0);
        verify(repo, Mockito.times(2)).findActiveNearbyReports(any(Point.class), eq(250.0), any(Instant.class));
    }

    @Test
    void infrastructureCircleUsesUpdatedRadius() {
        RegionalRiskCalculator regionalRiskCalculator = new RegionalRiskCalculator(fixedClock);
        RiskCircle circle = new RiskCircleBuilder(regionalRiskCalculator).build(
                new RiskCluster(
                        "cluster-1",
                        0.0,
                        0.0,
                        List.of(nearbyReport("INFRASTRUCTURE", 0.7, 1L, 0.0))
                )
        );

        assertThat(circle.radiusMeters()).isEqualTo(150.0);
        assertThat(circle.riskLevel()).isIn("LOW", "MEDIUM", "HIGH", "CRITICAL");
    }

    private NearbyReportProjection nearbyReport(String category, Double confidence, Long userId, double distanceMeters) {
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
                return "report";
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
                return fixedClock.instant();
            }

            @Override
            public String getStatus() {
                return "REVIEWING";
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
