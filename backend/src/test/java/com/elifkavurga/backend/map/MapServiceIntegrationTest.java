package com.elifkavurga.backend.map;

import com.elifkavurga.backend.map.dto.RiskResponse;
import com.elifkavurga.backend.map.service.MapService;
import com.elifkavurga.backend.report.dto.ReportResponse;
import com.elifkavurga.backend.report.entity.Report;
import com.elifkavurga.backend.report.entity.ReportCategory;
import com.elifkavurga.backend.report.repository.ReportRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.time.Instant;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
public class MapServiceIntegrationTest {

    @Autowired
    private MapService mapService;

    @Autowired
    private ReportRepository reportRepository;

    @BeforeEach
    void setup() {
        reportRepository.deleteAll();
        // create some reports
        Report r1 = new Report();
        r1.setCategory(ReportCategory.SUC);
        r1.setDescription("Crime close");
        r1.setLatitude(0.0);
        r1.setLongitude(0.0);
        r1.setCreatedAt(Instant.now().minusSeconds(60));
        reportRepository.save(r1);

        Report r2 = new Report();
        r2.setCategory(ReportCategory.TAKIP);
        r2.setDescription("Followed a bit further");
        r2.setLatitude(0.005); // ~550m
        r2.setLongitude(0.0);
        r2.setCreatedAt(Instant.now().minusSeconds(3600));
        reportRepository.save(r2);

        Report r3 = new Report();
        r3.setCategory(ReportCategory.HAYVAN);
        r3.setDescription("Animal far away");
        r3.setLatitude(0.02); // ~2km
        r3.setLongitude(0.0);
        r3.setCreatedAt(Instant.now().minusSeconds(3600));
        reportRepository.save(r3);

        // old report >7 days
        Report r4 = new Report();
        r4.setCategory(ReportCategory.SUC);
        r4.setDescription("Old crime");
        r4.setLatitude(0.0);
        r4.setLongitude(0.0);
        r4.setCreatedAt(Instant.now().minusSeconds(8 * 24 * 3600));
        reportRepository.save(r4);
    }

    @Test
    void riskCalculationProducesExpectedLevel() {
        RiskResponse resp = mapService.computeRisk(0.0, 0.0);
        // r1 has high weight, r2 medium; r3 excluded by distance, r4 excluded by age
        assertThat(resp.getScore()).isGreaterThan(0);
        assertThat(resp.getLevel()).isIn("low", "medium", "high");
    }

    @Test
    void findReportsNearbyReturnsExpectedList() {
        // radius 1000 meters should include r1 and r2 but not r3
        List<ReportResponse> reports = mapService.findReportsNearby(0.0, 0.0, 1000.0);
        assertThat(reports).hasSize(2);
        assertThat(reports).extracting("description").containsExactlyInAnyOrder("Crime close", "Followed a bit further");
    }

}
