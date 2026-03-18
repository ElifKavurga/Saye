package com.elifkavurga.backend.map.service;

import com.elifkavurga.backend.map.dto.RiskResponse;
import com.elifkavurga.backend.report.dto.ReportResponse;
import com.elifkavurga.backend.report.repository.ReportRepository;
import com.elifkavurga.backend.report.repository.projection.NearbyReportProjection;
import lombok.RequiredArgsConstructor;
import org.locationtech.jts.geom.Coordinate;
import org.locationtech.jts.geom.GeometryFactory;
import org.locationtech.jts.geom.PrecisionModel;
import org.locationtech.jts.geom.Point;
import org.springframework.stereotype.Service;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.util.List;

@Service
@RequiredArgsConstructor
public class MapServiceImpl implements MapService {

    private static final GeometryFactory GEOMETRY_FACTORY =
            new GeometryFactory(new PrecisionModel(), 4326);

    private final ReportRepository reportRepository;
    private final MapRiskProcessor mapRiskProcessor;
    private final Clock clock;

    private static final Duration REPORT_LIST_LOOKBACK = Duration.ofHours(12);
    private static final Duration RISK_LOOKBACK = Duration.ofDays(14);

    private List<NearbyReportProjection> queryNearby(double lat, double lng, double radiusMeters, Duration lookbackDuration) {
        Instant cutoff = Instant.now(clock).minus(lookbackDuration);
        return reportRepository.findActiveNearbyReports(createPoint(lat, lng), radiusMeters, cutoff);
    }

    @Override
    public List<ReportResponse> findReportsNearby(double lat, double lng, double radiusMeters) {
        return mapRiskProcessor.buildRiskReports(queryNearby(lat, lng, radiusMeters, REPORT_LIST_LOOKBACK));
    }

    @Override
    public RiskResponse computeRisk(double lat, double lng) {
        return mapRiskProcessor.computeOverallRisk(queryNearby(lat, lng, 1000.0, RISK_LOOKBACK));
    }

    private Point createPoint(double lat, double lng) {
        return GEOMETRY_FACTORY.createPoint(new Coordinate(lng, lat));
    }
}
