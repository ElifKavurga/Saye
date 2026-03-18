package com.elifkavurga.backend.map.service;

import com.elifkavurga.backend.map.risk.RiskCategory;
import com.elifkavurga.backend.map.risk.RiskResult;
import com.elifkavurga.backend.map.risk.RegionalRiskCalculator;
import org.springframework.stereotype.Service;

@Service
public class RiskCircleBuilder {

    private final RegionalRiskCalculator regionalRiskCalculator;

    public RiskCircleBuilder(RegionalRiskCalculator regionalRiskCalculator) {
        this.regionalRiskCalculator = regionalRiskCalculator;
    }

    public RiskCircle build(RiskCluster cluster) {
        RiskResult riskResult = regionalRiskCalculator.calculate(cluster.reports());
        CategoryProfile dominantProfile = cluster.reports().stream()
                .map(report -> profileForCategory(report.getCategory()))
                .max((left, right) -> Double.compare(left.baseRadiusMeters(), right.baseRadiusMeters()))
                .orElse(CategoryProfile.DEFAULT);

        int clusterSize = cluster.reports().size();
        double radiusMeters = dominantProfile.baseRadiusMeters() + (clusterSize * 40.0);
        double riskScore = riskResult.score();
        String riskLevel = riskResult.level().name();

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

    private CategoryProfile profileForCategory(String category) {
        String normalized = category == null ? "" : category.trim().toUpperCase();
        return switch (normalized) {
            case "SECURITY" -> new CategoryProfile(400.0, RiskCategory.SUC_GUVENLIK_IHLALI.getCap());
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
