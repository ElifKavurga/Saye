package com.elifkavurga.backend.map.risk;

public class CategoryRiskCalculator {

    public double calculateCategoryScore(RiskCategory category, int reportCount) {
        double diminishingSum = calculateDiminishingFactor(reportCount);
        double raw = category.getBaseRisk() * diminishingSum;
        return Math.min(category.getCap(), raw);
    }

    public double calculateDiminishingFactor(int count) {
        double factorSum = 0.0;
        for (int i = 0; i < count; i++) {
            factorSum += diminishWeightForIndex(i);
        }
        return factorSum;
    }

    public double diminishWeightForIndex(int index) {
        if (index < RiskCalculationConfig.DIMINISHING_WEIGHTS.size()) {
            return RiskCalculationConfig.DIMINISHING_WEIGHTS.get(index);
        }
        return RiskCalculationConfig.REPEATING_REPORT_MIN_WEIGHT;
    }
}
