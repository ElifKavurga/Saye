package com.elifkavurga.backend.map.service;

import com.elifkavurga.backend.map.dto.RiskResponse;
import com.elifkavurga.backend.report.dto.ReportResponse;
import com.elifkavurga.backend.report.repository.projection.NearbyReportProjection;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

@Service
public class MapRiskProcessor {

    private final RiskClusterService riskClusterService;
    private final RiskCircleBuilder riskCircleBuilder;

    public MapRiskProcessor(RiskClusterService riskClusterService, RiskCircleBuilder riskCircleBuilder) {
        this.riskClusterService = riskClusterService;
        this.riskCircleBuilder = riskCircleBuilder;
    }

    public List<ReportResponse> buildRiskReports(List<NearbyReportProjection> reports) {
        List<ReportResponse> responses = new ArrayList<>();
        for (RiskCluster cluster : riskClusterService.clusterReports(reports)) {
            RiskCircle riskCircle = riskCircleBuilder.build(cluster);
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
        double score = riskClusterService.clusterReports(reports).stream()
                .map(riskCircleBuilder::build)
                .mapToDouble(RiskCircle::riskScore)
                .sum();
        score = Math.min(100.0, score);

        String level;
        if (score >= 70.0) {
            level = "high";
        } else if (score >= 35.0) {
            level = "medium";
        } else {
            level = "low";
        }

        return RiskResponse.builder()
                .level(level)
                .score(score)
                .build();
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
