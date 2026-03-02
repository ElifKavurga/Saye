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
    @Schema(example = "ACTIVE")
    private String status;
    @Schema(example = "0.0")
    private Double confidenceScore;
}
