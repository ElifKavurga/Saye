package com.elifkavurga.backend.map.risk;

import com.elifkavurga.backend.report.repository.projection.NearbyReportProjection;

import java.time.Instant;

public record ReportSignal(
        Long id,
        Long userId,
        RiskCategory category,
        Instant createdAt,
        Double confidenceScore,
        Double latitude,
        Double longitude,
        Double distanceMeters,
        String status,
        String description
) {
    public static ReportSignal fromProjection(NearbyReportProjection projection) {
        return new ReportSignal(
                projection.getId(),
                projection.getUserId(),
                RiskCategory.fromLegacy(projection.getCategory()),
                projection.getCreatedAt(),
                projection.getConfidenceScore(),
                projection.getLatitude(),
                projection.getLongitude(),
                projection.getDistanceMeters(),
                projection.getStatus(),
                projection.getDescription()
        );
    }
}
