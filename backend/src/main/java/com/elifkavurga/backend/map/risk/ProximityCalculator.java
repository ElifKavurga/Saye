package com.elifkavurga.backend.map.risk;

public class ProximityCalculator {

    public double calculate(Double distanceMeters) {
        double distance = distanceMeters == null ? RiskCalculationConfig.PROXIMITY_FAR_METER : distanceMeters;

        if (distance <= RiskCalculationConfig.PROXIMITY_NEAR_METER) {
            return RiskCalculationConfig.PROXIMITY_NEAR_WEIGHT;
        }
        if (distance <= RiskCalculationConfig.PROXIMITY_MID_METER) {
            return RiskCalculationConfig.PROXIMITY_MID_WEIGHT;
        }
        if (distance <= RiskCalculationConfig.PROXIMITY_FAR_METER) {
            return RiskCalculationConfig.PROXIMITY_FAR_WEIGHT;
        }
        return RiskCalculationConfig.PROXIMITY_DISTANT_WEIGHT;
    }
}
