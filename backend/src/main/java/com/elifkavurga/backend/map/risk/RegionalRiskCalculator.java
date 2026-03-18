package com.elifkavurga.backend.map.risk;

import com.elifkavurga.backend.report.repository.projection.NearbyReportProjection;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.time.Clock;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

import static com.elifkavurga.backend.map.risk.RiskCalculationConfig.CRITICAL_DOMINANCE_CRIME_CONFIDENCE_COUNT;
import static com.elifkavurga.backend.map.risk.RiskCalculationConfig.CRITICAL_DOMINANCE_CRIME_CONFIDENCE_DOUBLE_COUNT;
import static com.elifkavurga.backend.map.risk.RiskCalculationConfig.CRITICAL_DOMINANCE_CONFIDENCE_DOUBLE_MIN;
import static com.elifkavurga.backend.map.risk.RiskCalculationConfig.CRITICAL_DOMINANCE_CONFIDENCE_MIN;

@Service
public class RegionalRiskCalculator {

    private static final Logger log = LoggerFactory.getLogger(RegionalRiskCalculator.class);

    private final DecayCalculator decayCalculator;
    private final ProximityCalculator proximityCalculator;
    private final ConfidenceScoreCalculator confidenceScoreCalculator;
    private final CategoryRiskCalculator categoryRiskCalculator;

    public RegionalRiskCalculator(Clock clock) {
        this.decayCalculator = new DecayCalculator(clock);
        this.proximityCalculator = new ProximityCalculator();
        this.confidenceScoreCalculator = new ConfidenceScoreCalculator(clock);
        this.categoryRiskCalculator = new CategoryRiskCalculator();
    }

    public RiskResult calculate(List<NearbyReportProjection> reports) {
        if (reports == null || reports.isEmpty()) {
            log.info("No reports passed to regional risk calculator.");
            return RiskResult.empty();
        }

        List<ReportSignal> signals = reports.stream()
                .filter(Objects::nonNull)
                .map(ReportSignal::fromProjection)
                .toList();

        List<ReportSignal> dedupedSignals = deduplicateSignals(signals);
        if (dedupedSignals.isEmpty()) {
            log.info("All reports were filtered during deduplication.");
            return RiskResult.empty();
        }

        List<ReportSignal> activeSignals = dedupedSignals.stream()
                .filter(signal -> decayCalculator.calculate(signal.category(), signal.createdAt()) > 0.0)
                .toList();

        if (activeSignals.isEmpty()) {
            log.info("No active reports after decay filtering.");
            return RiskResult.empty();
        }

        Map<RiskCategory, List<ReportSignal>> groupedSignals = activeSignals.stream()
                .collect(Collectors.groupingBy(ReportSignal::category, HashMap::new, Collectors.toList()));

        Map<String, Double> breakdown = new HashMap<>();
        List<String> reasons = new ArrayList<>();

        Map<ReportSignal, Double> confidenceBySignal = new HashMap<>();
        double rawScore = 0.0;
        for (Map.Entry<RiskCategory, List<ReportSignal>> entry : groupedSignals.entrySet()) {
            RiskCategory category = entry.getKey();
            List<ReportSignal> categorySignals = entry.getValue()
                    .stream()
                    .sorted(Comparator.comparing(ReportSignal::createdAt, Comparator.nullsLast(Comparator.reverseOrder())))
                    .collect(Collectors.toList());

            double diminishingSum = categoryRiskCalculator.calculateDiminishingFactor(categorySignals.size());
            if (diminishingSum <= 0.0) {
                continue;
            }
            double categoryBaseScore = Math.min(category.getCap(), category.getBaseRisk() * diminishingSum);
            double normalizedSum = 0.0;
            for (int i = 0; i < categorySignals.size(); i++) {
                ReportSignal signal = categorySignals.get(i);
                double decay = decayCalculator.calculate(category, signal.createdAt());
                if (decay <= 0.0) {
                    continue;
                }
                normalizedSum += categoryRiskCalculator.diminishWeightForIndex(i);
            }
            if (normalizedSum <= 0.0) {
                continue;
            }

            double categoryContribution = 0.0;
            for (int i = 0; i < categorySignals.size(); i++) {
                ReportSignal signal = categorySignals.get(i);
                double decay = decayCalculator.calculate(category, signal.createdAt());
                if (decay <= 0.0) {
                    log.debug(
                            "Signal excluded due to age decay rule. category={} signalId={} createdAt={}",
                            category,
                            signal.id(),
                            signal.createdAt()
                    );
                    continue;
                }

                double weight = categoryRiskCalculator.diminishWeightForIndex(i);
                double proximity = proximityCalculator.calculate(signal.distanceMeters());
                int nearbyIndependent = countNearbyIndependentSignals(categorySignals, signal);
                boolean contradictory = hasContradictorySignalWithinWindow(activeSignals, signal);
                boolean longUnverifiedSingleton = isLongUnverifiedSingleton(categorySignals, signal);
                double confidence = confidenceScoreCalculator.calculate(
                        signal,
                        nearbyIndependent,
                        contradictory,
                        longUnverifiedSingleton
                );
                confidenceBySignal.put(signal, confidence);
                categoryContribution += categoryBaseScore
                        * decay
                        * confidence
                        * proximity
                        * (weight / normalizedSum);

                reasons.add(String.format(
                        Locale.ROOT,
                        "category=%s signalId=%s weight=%.2f decay=%.2f confidence=%.2f proximity=%.2f",
                        category,
                        signal.id(),
                        weight,
                        decay,
                        confidence,
                        proximity
                ));
            }
            breakdown.put(category.name(), round(categoryContribution));
            rawScore += categoryContribution;
            log.debug("Category contribution. category={} score={}", category, categoryContribution);
        }

        double enforcedScore = applyCriticalDominanceRules(activeSignals, confidenceBySignal, rawScore);
        double rounded = round(enforcedScore);
        RiskLevel level = RiskLevel.fromScore(rounded);
        log.info("Regional risk calculated. raw={} adjusted={} level={}", rawScore, rounded, level);

        return RiskResult.from(rounded, reasons, breakdown);
    }

    private int countNearbyIndependentSignals(List<ReportSignal> categorySignals, ReportSignal signal) {
        return (int) categorySignals.stream()
                .filter(candidate -> !java.util.Objects.equals(candidate.id(), signal.id()))
                .filter(candidate -> candidate.userId() != null && signal.userId() != null)
                .filter(candidate -> !candidate.userId().equals(signal.userId()))
                .filter(candidate -> isNear(candidate, signal, RiskCalculationConfig.CRITICAL_REGION_DISTANCE_METERS))
                .count();
    }

    private boolean hasContradictorySignalWithinWindow(List<ReportSignal> categorySignals, ReportSignal signal) {
        return categorySignals.stream()
                .anyMatch(candidate -> !Objects.equals(candidate.id(), signal.id())
                        && isNear(signal, candidate, RiskCalculationConfig.CRITICAL_REGION_DISTANCE_METERS)
                        && !candidate.category().equals(signal.category())
                        && sameUser(candidate, signal)
                        && createdWithin(signal, candidate, RiskCalculationConfig.DUPLICATE_WINDOW)
                );
    }

    private boolean isLongUnverifiedSingleton(List<ReportSignal> categorySignals, ReportSignal signal) {
        long pendingCount = categorySignals.stream()
                .filter(candidate -> "PENDING".equalsIgnoreCase(candidate.status()))
                .count();
        return pendingCount == 1 && confidenceScoreCalculator.isLongUnverifiedSingleton(signal);
    }

    private boolean isNear(ReportSignal left, ReportSignal right, double maxDistanceMeters) {
        double distance = calculateDistanceMeters(left.latitude(), left.longitude(), right.latitude(), right.longitude());
        return distance <= maxDistanceMeters;
    }

    private List<ReportSignal> deduplicateSignals(List<ReportSignal> signals) {
        List<ReportSignal> ordered = signals.stream()
                .sorted(Comparator.comparing(ReportSignal::createdAt, Comparator.nullsLast(Comparator.reverseOrder())))
                .collect(Collectors.toList());
        // TODO: device/ip identity is not available in current schema.
        // Duplicate reduction is currently same-user + same-location + 10-minute-window only.

        List<ReportSignal> deduped = new ArrayList<>();
        for (ReportSignal current : ordered) {
            boolean duplicateFound = deduped.stream().anyMatch(existing -> isDuplicate(existing, current));
            if (duplicateFound) {
                int existingIndex = indexOfExistingDuplicate(deduped, current);
                if (existingIndex >= 0) {
                    ReportSignal existing = deduped.get(existingIndex);
                    deduped.set(existingIndex, pickMoreInformative(existing, current));
                }
                continue;
            }
            deduped.add(current);
        }
        return deduped;
    }

    private int indexOfExistingDuplicate(List<ReportSignal> deduped, ReportSignal current) {
        for (int i = 0; i < deduped.size(); i++) {
            if (isDuplicate(deduped.get(i), current)) {
                return i;
            }
        }
        return -1;
    }

    private boolean isDuplicate(ReportSignal existing, ReportSignal candidate) {
        if (existing.userId() == null || candidate.userId() == null) {
            return false;
        }
        if (!existing.userId().equals(candidate.userId())) {
            return false;
        }
        if (existing.category() != candidate.category()) {
            return false;
        }

        Instant existingTime = existing.createdAt() == null ? Instant.EPOCH : existing.createdAt();
        Instant candidateTime = candidate.createdAt() == null ? Instant.EPOCH : candidate.createdAt();
        long minutesBetween = Math.abs(java.time.Duration.between(existingTime, candidateTime).toMinutes());
        return minutesBetween <= RiskCalculationConfig.DUPLICATE_WINDOW.toMinutes()
                && isNear(existing, candidate, RiskCalculationConfig.DUPLICATE_REGION_DISTANCE_METERS);
    }

    private ReportSignal pickMoreInformative(ReportSignal existing, ReportSignal candidate) {
        Double existingConfidence = existing.confidenceScore() == null ? 0.0 : existing.confidenceScore();
        Double candidateConfidence = candidate.confidenceScore() == null ? 0.0 : candidate.confidenceScore();
        if (candidateConfidence >= existingConfidence) {
            return candidate;
        }
        return existing;
    }

    private boolean createdWithin(ReportSignal left, ReportSignal right, java.time.Duration duration) {
        Instant leftTime = left.createdAt() == null ? Instant.EPOCH : left.createdAt();
        Instant rightTime = right.createdAt() == null ? Instant.EPOCH : right.createdAt();
        return Math.abs(java.time.Duration.between(leftTime, rightTime).toMinutes()) <= duration.toMinutes();
    }

    private boolean sameUser(ReportSignal left, ReportSignal right) {
        return left.userId() != null && left.userId().equals(right.userId());
    }

    private double applyCriticalDominanceRules(List<ReportSignal> signals, Map<ReportSignal, Double> signalConfidence, double score) {
        boolean hasCrime = signals.stream()
                .anyMatch(signal -> signal.category() == RiskCategory.SUC_GUVENLIK_IHLALI);
        boolean containsOnlySoftCategories = signals.stream()
                .map(ReportSignal::category)
                .allMatch(category ->
                        category == RiskCategory.AYDINLATMA_SORUNU
                                || category == RiskCategory.ALTYAPI_FIZIKI_TEHLIKE);

        java.util.function.Function<ReportSignal, Double> confidenceResolver = signal -> signalConfidence.getOrDefault(
                signal,
                confidenceScoreCalculator.calculate(
                        signal,
                        countNearbyIndependentSignals(signals, signal),
                        hasContradictorySignalWithinWindow(signals, signal),
                        isLongUnverifiedSingleton(signals, signal)
                )
        );

        long highConfidenceDistinctUsers = signals.stream()
                .filter(signal -> signal.category() == RiskCategory.SUC_GUVENLIK_IHLALI)
                .filter(signal -> confidenceResolver.apply(signal) >= CRITICAL_DOMINANCE_CONFIDENCE_MIN)
                .map(ReportSignal::userId)
                .filter(Objects::nonNull)
                .collect(Collectors.toSet())
                .size();

        long twoHighConfidenceDistinctUsers = signals.stream()
                .filter(signal -> signal.category() == RiskCategory.SUC_GUVENLIK_IHLALI)
                .filter(signal -> confidenceResolver.apply(signal) >= CRITICAL_DOMINANCE_CONFIDENCE_DOUBLE_MIN)
                .map(ReportSignal::userId)
                .filter(Objects::nonNull)
                .collect(Collectors.toSet())
                .size();

        if (highConfidenceDistinctUsers >= CRITICAL_DOMINANCE_CRIME_CONFIDENCE_DOUBLE_COUNT
                && twoHighConfidenceDistinctUsers >= CRITICAL_DOMINANCE_CRIME_CONFIDENCE_DOUBLE_COUNT) {
            return Math.max(score, 80.0);
        }

        if (highConfidenceDistinctUsers >= CRITICAL_DOMINANCE_CRIME_CONFIDENCE_COUNT) {
            return Math.max(score, 60.0);
        }

        double maxConfidence = signals.stream()
                .map(confidenceResolver)
                .max(Double::compareTo)
                .orElse(RiskCalculationConfig.MIN_CONFIDENCE);
        if (maxConfidence < RiskCalculationConfig.CRITICAL_SINGLE_REPORT_TRIGGER && score >= 80.0) {
            return Math.max(60.0, Math.min(79.99, score));
        }

        if (!hasCrime && containsOnlySoftCategories && score >= 80.0) {
            return Math.max(60.0, Math.min(79.99, score));
        }
        return score;
    }

    private double calculateDistanceMeters(Double lat1, Double lon1, Double lat2, Double lon2) {
        if (lat1 == null || lon1 == null || lat2 == null || lon2 == null) {
            return RiskCalculationConfig.DUPLICATE_REGION_DISTANCE_METERS;
        }
        double earthRadiusMeters = 6_371_000.0;
        double lat1Rad = Math.toRadians(lat1);
        double lat2Rad = Math.toRadians(lat2);
        double deltaLat = Math.toRadians(lat2 - lat1);
        double deltaLon = Math.toRadians(lon2 - lon1);

        double a = Math.sin(deltaLat / 2) * Math.sin(deltaLat / 2)
                + Math.cos(lat1Rad) * Math.cos(lat2Rad)
                * Math.sin(deltaLon / 2) * Math.sin(deltaLon / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return earthRadiusMeters * c;
    }

    private double round(double value) {
        return Math.round(value * 100.0) / 100.0;
    }
}

