package com.elifkavurga.backend.map.service;

import com.elifkavurga.backend.report.repository.projection.NearbyReportProjection;

import java.util.List;

public record RiskCluster(
        String id,
        double centerLatitude,
        double centerLongitude,
        List<NearbyReportProjection> reports
) {
}
