package com.elifkavurga.backend.map.service;

import com.elifkavurga.backend.map.dto.RiskResponse;
import com.elifkavurga.backend.report.dto.ReportResponse;
import com.elifkavurga.backend.report.entity.Report;
import com.elifkavurga.backend.report.repository.ReportRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class MapServiceImpl implements MapService {

    private final ReportRepository reportRepository;

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

    @Override
    public List<ReportResponse> findReportsNearby(double lat, double lng, double radiusMeters) {
        return reportRepository.findAll().stream()
                .filter(r -> r.getLatitude() != null && r.getLongitude() != null)
                .filter(r -> distanceMeters(lat, lng, r.getLatitude(), r.getLongitude()) <= radiusMeters)
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    public RiskResponse computeRisk(double lat, double lng) {
        // MVP risk calculation:
        // - Only consider reports in the last 7 days
        // - Apply category weights (e.g. SUC more important)
        // - Apply distance weight: closer reports have larger effect
        // - Aggregate weighted sum -> normalize to 0-100

        Instant now = Instant.now();
        Instant cutoff = now.minus(7, ChronoUnit.DAYS);

        final double maxRadius = 1000.0; // meters considered for strong influence

        // category weights (tuneable)
        java.util.Map<String, Double> categoryWeights = java.util.Map.of(
                "SUC", 3.0,
                "TAKIP", 2.5,
                "HAYVAN", 1.0,
                "SAGLIK", 2.0,
                "ARIZA", 1.0,
                "TRAFIK", 2.0
        );

        double rawScore = 0.0;

        for (Report r : reportRepository.findAll()) {
            if (r.getCreatedAt() == null || r.getLatitude() == null || r.getLongitude() == null) {
                continue;
            }
            if (r.getCreatedAt().isBefore(cutoff)) {
                continue; // older than 7 days
            }

            double dist = distanceMeters(lat, lng, r.getLatitude(), r.getLongitude());
            if (dist > maxRadius) {
                continue; // ignore reports outside influence radius
            }

            double distanceFactor = 1.0 - (dist / maxRadius); // 1.0 (same location) -> 0.0 (at maxRadius)

            String cat = r.getCategory() != null ? r.getCategory().name() : "";
            double catWeight = categoryWeights.getOrDefault(cat, 1.0);

            rawScore += catWeight * distanceFactor;
        }

        // Normalize rawScore to 0-100. Multiplier chosen empirically for MVP.
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

    private ReportResponse toResponse(Report r) {
        return ReportResponse.builder()
                .id(r.getId())
                .userId(r.getUserId())
                .category(r.getCategory().name())
                .description(r.getDescription())
                .latitude(r.getLatitude())
                .longitude(r.getLongitude())
                .createdAt(r.getCreatedAt())
                .status(r.getStatus().name())
                .confidenceScore(r.getConfidenceScore())
                .build();
    }
}
