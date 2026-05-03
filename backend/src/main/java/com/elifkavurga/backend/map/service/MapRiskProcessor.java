package com.elifkavurga.backend.map.service;

import com.elifkavurga.backend.map.dto.RiskResponse;
import com.elifkavurga.backend.map.risk.RiskLevel;
import com.elifkavurga.backend.report.dto.ReportResponse;
import com.elifkavurga.backend.report.repository.projection.NearbyReportProjection;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class MapRiskProcessor {

    private static final Logger log = LoggerFactory.getLogger(MapRiskProcessor.class);

    private final RiskClusterService riskClusterService;
    private final RiskCircleBuilder riskCircleBuilder;

    public MapRiskProcessor(RiskClusterService riskClusterService, RiskCircleBuilder riskCircleBuilder) {
        this.riskClusterService = riskClusterService;
        this.riskCircleBuilder = riskCircleBuilder;
    }

    public List<ReportResponse> buildRiskReports(List<NearbyReportProjection> reports) {
        log.info(
                "Starting report risk enrichment. incomingReports={}",
                reports == null ? 0 : reports.size()
        );
        List<ReportResponse> responses = new ArrayList<>();
        for (RiskCluster cluster : riskClusterService.clusterReports(reports)) {
            RiskCircle riskCircle = riskCircleBuilder.build(cluster);
            log.debug(
                    "Cluster scored. id={} clusterSize={} riskScore={} riskLevel={}",
                    riskCircle.id(),
                    riskCircle.clusterSize(),
                    riskCircle.riskScore(),
                    riskCircle.riskLevel()
            );
            for (NearbyReportProjection report : cluster.reports()) {
                responses.add(toResponse(report, riskCircle));
            }
        }

        responses.sort(Comparator
                .comparing(ReportResponse::getRiskScore, Comparator.nullsLast(Comparator.reverseOrder()))
                .thenComparing(ReportResponse::getCreatedAt, Comparator.nullsLast(Comparator.reverseOrder())));
        return responses;
    }

    public RiskResponse computeOverallRisk(List<NearbyReportProjection> reports) {
        List<RiskCircle> circles = riskClusterService.clusterReports(reports).stream()
                .map(riskCircleBuilder::build)
                .collect(Collectors.toList());

        double score = calculateWeightedOverallScore(circles);
        score = Math.min(100.0, score);
        RiskLevel level = RiskLevel.fromScore(score);

        log.info(
                "Computed overall risk. score={} level={} circles={}",
                score,
                level,
                circles.size()
        );

        circles.forEach(circle -> log.debug(
                "Component circle {} => score={} level={} clusterSize={}",
                circle.id(),
                circle.riskScore(),
                circle.riskLevel(),
                circle.clusterSize()
        ));

        return RiskResponse.builder()
                .level(level.name())
                .score(score)
                .build();
    }

    private double calculateWeightedOverallScore(List<RiskCircle> circles) {
        if (circles.isEmpty()) {
            return 0.0;
        }

        double highestScore = circles.stream()
                .mapToDouble(RiskCircle::riskScore)
                .max()
                .orElse(0.0);
        double supportingScore = circles.stream()
                .mapToDouble(RiskCircle::riskScore)
                .sum() - highestScore;
        return highestScore + (supportingScore * 0.15);
    }

    private ReportResponse toResponse(NearbyReportProjection report, RiskCircle riskCircle) {
        return ReportResponse.builder()
                .id(report.getId())
                .userId(report.getUserId())
                .category(report.getCategory())
                .description(report.getDescription())
                .latitude(report.getLatitude())
                .longitude(report.getLongitude())
                .createdAt(report.getCreatedAt())
                .status(report.getStatus())
                .confidenceScore(report.getConfidenceScore())
                .riskRadiusMeters(riskCircle.radiusMeters())
                .riskLevel(riskCircle.riskLevel())
                .riskScore(riskCircle.riskScore())
                .clusterSize(riskCircle.clusterSize())
                .riskCenterLatitude(riskCircle.centerLatitude())
                .riskCenterLongitude(riskCircle.centerLongitude())
                .riskCircleId(riskCircle.id())
                .build();
    }
}
