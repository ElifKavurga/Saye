package com.elifkavurga.backend.map.service;

import org.springframework.stereotype.Service;

@Service
public class RiskCircleBuilder {

    public RiskCircle build(RiskCluster cluster) {
        CategoryProfile dominantProfile = cluster.reports().stream()
                .map(report -> profileForCategory(report.getCategory()))
                .max((left, right) -> Double.compare(left.baseScore(), right.baseScore()))
                .orElse(CategoryProfile.DEFAULT);

        int clusterSize = cluster.reports().size();
        double radiusMeters = dominantProfile.baseRadiusMeters() + (clusterSize * 40.0);
        double riskScore = Math.min(100.0, dominantProfile.baseScore() + (clusterSize * 10.0));
        String riskLevel = riskLevelForScore(riskScore);

        return new RiskCircle(
                cluster.id(),
                cluster.centerLatitude(),
                cluster.centerLongitude(),
                radiusMeters,
                riskScore,
                riskLevel,
                clusterSize
        );
    }

    private String riskLevelForScore(double riskScore) {
        if (riskScore >= 70.0) {
            return "HIGH";
        }
        if (riskScore >= 35.0) {
            return "MEDIUM";
        }
        return "LOW";
    }

    private CategoryProfile profileForCategory(String category) {
        String normalized = category == null ? "" : category.trim().toUpperCase();
        return switch (normalized) {
            case "SECURITY" -> new CategoryProfile(400.0, 60.0);
            case "ANIMALS" -> new CategoryProfile(360.0, 55.0);
            // The builder adds 40m per report when composing the final circle.
            case "LIGHTING", "HEALTH" -> new CategoryProfile(160.0, 35.0);
            case "INFRASTRUCTURE", "TRACKING" -> new CategoryProfile(110.0, 35.0);
            case "TRAFFIC" -> new CategoryProfile(150.0, 30.0);
            default -> CategoryProfile.DEFAULT;
        };
    }

    private record CategoryProfile(double baseRadiusMeters, double baseScore) {
        private static final CategoryProfile DEFAULT = new CategoryProfile(180.0, 25.0);
    }
}
