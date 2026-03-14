package com.elifkavurga.backend.report.repository.projection;

import java.time.Instant;

public interface NearbyReportProjection {
    Long getId();

    Long getUserId();

    String getCategory();

    String getDescription();

    Double getLatitude();

    Double getLongitude();

    Instant getCreatedAt();

    String getStatus();

    Double getConfidenceScore();

    Double getDistanceMeters();
}
