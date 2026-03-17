package com.elifkavurga.backend.report.dto;

import lombok.Builder;
import lombok.Getter;
import io.swagger.v3.oas.annotations.media.Schema;

import java.time.Instant;

@Getter
@Builder
@Schema(description = "Durum bildirimi cevabi")
public class ReportResponse {
    @Schema(example = "12")
    private Long id;
    @Schema(example = "30")
    private Long userId;
    @Schema(example = "SUC")
    private String category;
    @Schema(example = "Parkta supheli bir durum var")
    private String description;
    @Schema(example = "41.0082")
    private Double latitude;
    @Schema(example = "28.9784")
    private Double longitude;
    @Schema(example = "2026-03-02T09:15:00Z")
    private Instant createdAt;
    @Schema(example = "PENDING")
    private String status;
    @Schema(example = "0.0")
    private Double confidenceScore;
    @Schema(example = "150.0")
    private Double riskRadiusMeters;
    @Schema(example = "MEDIUM")
    private String riskLevel;
    @Schema(example = "61.0")
    private Double riskScore;
    @Schema(example = "2")
    private Integer clusterSize;
    @Schema(example = "41.0085")
    private Double riskCenterLatitude;
    @Schema(example = "28.9782")
    private Double riskCenterLongitude;
    @Schema(example = "cluster-41.008500-28.978200")
    private String riskCircleId;
}
