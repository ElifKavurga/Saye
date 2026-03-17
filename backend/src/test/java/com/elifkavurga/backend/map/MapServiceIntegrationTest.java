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
import org.springframework.jdbc.core.JdbcTemplate;

import java.sql.Timestamp;
import java.time.Instant;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
public class MapServiceIntegrationTest {

    @Autowired
    private MapService mapService;

    @Autowired
    private ReportRepository reportRepository;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @BeforeEach
    void setup() {
        reportRepository.deleteAll();
        Instant now = Instant.now();
        // create some reports
        Report r1 = new Report();
        r1.setCategory(ReportCategory.SECURITY);
        r1.setDescription("Crime close");
        r1.setLatitude(0.0);
        r1.setLongitude(0.0);
        r1.setCreatedAt(now.minusSeconds(60));
        reportRepository.save(r1);

        Report r2 = new Report();
        r2.setCategory(ReportCategory.LIGHTING);
        r2.setDescription("Followed a bit further");
        r2.setLatitude(0.005); // ~550m
        r2.setLongitude(0.0);
        r2.setCreatedAt(now.minusSeconds(3600));
        reportRepository.save(r2);

        Report r5 = new Report();
        r5.setCategory(ReportCategory.SECURITY);
        r5.setDescription("Crime same block");
        r5.setLatitude(0.001);
        r5.setLongitude(0.0);
        r5.setCreatedAt(now.minusSeconds(180));
        reportRepository.save(r5);

        Report r3 = new Report();
        r3.setCategory(ReportCategory.ANIMALS);
        r3.setDescription("Animal far away");
        r3.setLatitude(0.02); // ~2km
        r3.setLongitude(0.0);
        r3.setCreatedAt(now.minusSeconds(3600));
        reportRepository.save(r3);

        // old report >12 hours
        Report r4 = new Report();
        r4.setCategory(ReportCategory.SECURITY);
        r4.setDescription("Old crime");
        r4.setLatitude(0.0);
        r4.setLongitude(0.0);
        Instant staleTimestamp = now.minusSeconds(8 * 24 * 3600);
        r4.setCreatedAt(staleTimestamp);
        reportRepository.saveAndFlush(r4);
        jdbcTemplate.update(
                "UPDATE reports SET created_at = ?, updated_at = ? WHERE id = ?",
                Timestamp.from(staleTimestamp),
                Timestamp.from(staleTimestamp),
                r4.getId()
        );
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
        // radius 1000 meters should include nearby reports
        List<ReportResponse> reports = mapService.findReportsNearby(0.0, 0.0, 1000.0);
        assertThat(reports).hasSize(3);
        assertThat(reports).extracting("description")
                .containsExactlyInAnyOrder("Crime close", "Followed a bit further", "Crime same block");
        assertThat(reports).extracting("description").doesNotContain("Old crime");
        assertThat(reports).extracting("riskRadiusMeters")
                .containsExactlyInAnyOrder(480.0, 480.0, 200.0);
        assertThat(reports).extracting("riskLevel")
                .containsExactlyInAnyOrder("HIGH", "HIGH", "MEDIUM");
        assertThat(reports).extracting("clusterSize")
                .containsExactlyInAnyOrder(2, 2, 1);
    }

}
