package com.elifkavurga.backend.map.service;

import com.elifkavurga.backend.map.dto.RiskResponse;
import com.elifkavurga.backend.report.dto.ReportResponse;
import com.elifkavurga.backend.report.entity.Report;
import com.elifkavurga.backend.report.repository.ReportRepository;
import org.locationtech.jts.geom.Coordinate;
import org.locationtech.jts.geom.GeometryFactory;
import org.locationtech.jts.geom.PrecisionModel;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.Clock;
import java.time.Instant;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class MapServiceImpl implements MapService {

    private final ReportRepository reportRepository;
    private final Clock clock;

    private static double distanceMeters(double lat1, double lng1, double lat2, double lng2) {
        // haversine formula
        double earthRadius = 6371000; // meters
        double dLat = Math.toRadians(lat2 - lat1);
        double dLng = Math.toRadians(lng2 - lng1);
        double a = Math.sin(dLat/2) * Math.sin(dLat/2) +
                   Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) *
                   Math.sin(dLng/2) * Math.sin(dLng/2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
        return earthRadius * c;
    }

    private List<Report> queryNearby(double lat, double lng, double radiusMeters) {
        Instant cutoff = Instant.now(clock).minus(12, java.time.temporal.ChronoUnit.HOURS);
        try {
            GeometryFactory gf = new GeometryFactory(new PrecisionModel(), 4326);
            List<Report> candidates = reportRepository.findByLocationWithinRadius(
                    gf.createPoint(new Coordinate(lng, lat)),
                    radiusMeters
            );
            // Keep deterministic behavior across different DB spatial implementations.
            return candidates.stream()
                    .filter(r -> isActive(r, cutoff))
                    .filter(r -> r.getLatitude() != null && r.getLongitude() != null)
                    .filter(r -> distanceMeters(lat, lng, r.getLatitude(), r.getLongitude()) <= radiusMeters)
                    .collect(Collectors.toList());
        } catch (Exception ex) {
            // log and fallback to manual filtering (e.g. H2 lacks ST_DWithin)
            System.out.println("spatial query failed, falling back: " + ex.getMessage());
            return reportRepository.findActiveReportsWithin12Hours().stream()
                    .filter(r -> r.getLatitude() != null && r.getLongitude() != null)
                    .filter(r -> distanceMeters(lat, lng, r.getLatitude(), r.getLongitude()) <= radiusMeters)
                    .collect(Collectors.toList());
        }
    }

    @Override
    public List<ReportResponse> findReportsNearby(double lat, double lng, double radiusMeters) {
        return queryNearby(lat, lng, radiusMeters).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    public RiskResponse computeRisk(double lat, double lng) {
        Instant now = Instant.now(clock);
        Instant cutoff = now.minus(12, java.time.temporal.ChronoUnit.HOURS);
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

        List<Report> nearby = queryNearby(lat, lng, maxRadius);
        for (Report r : nearby) {
            if (!isActive(r, cutoff)) continue;

            Double rlat = r.getLatitude();
            Double rlng = r.getLongitude();
            if (rlat == null || rlng == null) continue;

            double dist = distanceMeters(lat, lng, rlat, rlng);
            if (dist > maxRadius) continue;
            double distanceFactor = 1.0 - (dist / maxRadius);
            String cat = r.getCategory() != null ? r.getCategory().name() : "";
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

    private boolean isActive(Report r, Instant cutoff) {
        Instant createdAt = r.getCreatedAt();
        Instant updatedAt = r.getUpdatedAt();
        return (createdAt != null && !createdAt.isBefore(cutoff))
                || (updatedAt != null && !updatedAt.isBefore(cutoff));
    }

    private ReportResponse toResponse(Report r) {
        return ReportResponse.builder()
                .id(r.getId())
                .userId(r.getUserId())
                .category(r.getCategory() != null ? r.getCategory().name() : null)
                .description(r.getDescription())
                .latitude(r.getLatitude())
                .longitude(r.getLongitude())
                .createdAt(r.getCreatedAt())
                .status(r.getStatus() != null ? r.getStatus().name() : null)
                .confidenceScore(r.getConfidenceScore())
                .build();
    }
}
