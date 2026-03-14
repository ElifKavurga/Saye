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
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.List;

@Service
@RequiredArgsConstructor
public class MapServiceImpl implements MapService {

    private static final GeometryFactory GEOMETRY_FACTORY =
            new GeometryFactory(new PrecisionModel(), 4326);

    private final ReportRepository reportRepository;
    private final Clock clock;

    private List<NearbyReportProjection> queryNearby(double lat, double lng, double radiusMeters) {
        Instant cutoff = Instant.now(clock).minus(12, ChronoUnit.HOURS);
        return reportRepository.findActiveNearbyReports(createPoint(lat, lng), radiusMeters, cutoff);
    }

    @Override
    public List<ReportResponse> findReportsNearby(double lat, double lng, double radiusMeters) {
        return queryNearby(lat, lng, radiusMeters).stream()
                .map(this::toResponse)
                .toList();
    }

    @Override
    public RiskResponse computeRisk(double lat, double lng) {
        final double maxRadius = 1000.0; // meters

        java.util.Map<String, Double> categoryWeights = java.util.Map.of(
                "SECURITY", 3.0,
                "LIGHTING", 2.0,
                "ANIMALS", 1.0,
                "HEALTH", 2.0,
                "INFRASTRUCTURE", 1.0,
                "TRAFFIC", 2.0
        );

        double rawScore = 0.0;

        List<NearbyReportProjection> nearby = queryNearby(lat, lng, maxRadius);
        for (NearbyReportProjection report : nearby) {
            Double distanceMeters = report.getDistanceMeters();
            if (distanceMeters == null) {
                continue;
            }

            double distanceFactor = Math.max(0.0, 1.0 - (distanceMeters / maxRadius));
            String cat = report.getCategory() != null ? report.getCategory() : "";
            double catWeight = categoryWeights.getOrDefault(cat, 1.0);
            rawScore += catWeight * distanceFactor;
        }

        double score = Math.min(100.0, rawScore * 10.0);
        String level;
        if (score <= 30.0) {
            level = "low";
        } else if (score <= 60.0) {
            level = "medium";
        } else {
            level = "high";
        }

        return RiskResponse.builder()
                .level(level)
                .score(score)
                .build();
    }

    private Point createPoint(double lat, double lng) {
        return GEOMETRY_FACTORY.createPoint(new Coordinate(lng, lat));
    }

    private ReportResponse toResponse(NearbyReportProjection report) {
        return ReportResponse.builder()
                .id(report.getId())
                .userId(report.getUserId())
                .category(report.getCategory())
                .description(report.getDescription())
                .latitude(report.getLatitude())
                .longitude(report.getLongitude())
                .createdAt(report.getCreatedAt())
                .status(report.getStatus())
                .confidenceScore(report.getConfidenceScore())
                .build();
    }
}
