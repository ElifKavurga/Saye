package com.elifkavurga.backend.map;

import com.elifkavurga.backend.map.dto.RiskResponse;
import com.elifkavurga.backend.map.service.MapServiceImpl;
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
import static org.mockito.Mockito.when;

class MapServiceUnitTest {

    private ReportRepository repo;
    private MapServiceImpl service;
    private Clock fixedClock;

    @BeforeEach
    void setup() {
        repo = Mockito.mock(ReportRepository.class);
        // fix clock to a known instant
        fixedClock = Clock.fixed(Instant.parse("2026-03-02T00:00:00Z"), ZoneOffset.UTC);
        service = new MapServiceImpl(repo, fixedClock);
    }

    @Test
    void computeRiskDeterministic() {
        NearbyReportProjection r1 = nearbyReport("SECURITY", 0.0);
        NearbyReportProjection r2 = nearbyReport("LIGHTING", 500.0);

        when(repo.findActiveNearbyReports(any(Point.class), anyDouble(), any(Instant.class)))
                .thenReturn(List.of(r1, r2));

        RiskResponse first = service.computeRisk(0.0, 0.0);
        RiskResponse second = service.computeRisk(0.0, 0.0);

        // deterministic: subsequent calls return same value
        assertThat(first).isEqualTo(second);
        assertThat(first.getScore()).isGreaterThan(0);
        assertThat(first.getLevel()).isIn("low", "medium", "high");
        // based on weights/security+lighting this should be around 40-45 => medium
        assertThat(first.getLevel()).isEqualTo("medium");
        assertThat(first.getScore()).isBetween(39.9, 40.1);
    }

    private NearbyReportProjection nearbyReport(String category, double distanceMeters) {
        return new NearbyReportProjection() {
            @Override
            public Long getId() {
                return 1L;
            }

            @Override
            public Long getUserId() {
                return 10L;
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
                return Instant.now(fixedClock);
            }

            @Override
            public String getStatus() {
                return "PENDING";
            }

            @Override
            public Double getConfidenceScore() {
                return null;
            }

            @Override
            public Double getDistanceMeters() {
                return distanceMeters;
            }
        };
    }
}
