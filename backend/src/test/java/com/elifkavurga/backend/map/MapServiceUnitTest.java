package com.elifkavurga.backend.map;

import com.elifkavurga.backend.map.dto.RiskResponse;
import com.elifkavurga.backend.map.service.MapServiceImpl;
import com.elifkavurga.backend.report.entity.Report;
import com.elifkavurga.backend.report.entity.ReportCategory;
import com.elifkavurga.backend.report.repository.ReportRepository;
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
        // create reports such that we can compute known score
        Report r1 = new Report();
        r1.setCategory(ReportCategory.SECURITY);
        r1.setCreatedAt(Instant.now(fixedClock));
        // same location (0,0)
        r1.setLatitude(0.0);
        r1.setLongitude(0.0);

        Report r2 = new Report();
        r2.setCategory(ReportCategory.LIGHTING);
        r2.setCreatedAt(Instant.now(fixedClock));
        // ~500m away on latitude
        r2.setLatitude(0.0045); // approx 500m
        r2.setLongitude(0.0);

        // report outside radius
        Report r3 = new Report();
        r3.setCategory(ReportCategory.ANIMALS);
        r3.setCreatedAt(Instant.now(fixedClock));
        r3.setLatitude(0.02);
        r3.setLongitude(0.0);

        when(repo.findByLocationWithinRadius(any(Point.class), anyDouble()))
                .thenReturn(List.of(r1, r2));

        RiskResponse first = service.computeRisk(0.0, 0.0);
        RiskResponse second = service.computeRisk(0.0, 0.0);

        // deterministic: subsequent calls return same value
        assertThat(first).isEqualTo(second);
        assertThat(first.getScore()).isGreaterThan(0);
        assertThat(first.getLevel()).isIn("low", "medium", "high");
        // based on weights/security+lighting this should be around 40-45 => medium
        assertThat(first.getLevel()).isEqualTo("medium");
        assertThat(first.getScore()).isBetween(39.0, 45.0);
    }
}
