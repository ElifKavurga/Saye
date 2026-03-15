package com.elifkavurga.backend.map.service;

public record RiskCircle(
        String id,
        double centerLatitude,
        double centerLongitude,
        double radiusMeters,
        double riskScore,
        String riskLevel,
        int clusterSize
) {
}
