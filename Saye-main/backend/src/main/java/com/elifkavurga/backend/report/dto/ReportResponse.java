package com.elifkavurga.backend.report.dto;

import lombok.Builder;
import lombok.Getter;

import java.time.Instant;

@Getter
@Builder
public class ReportResponse {
    private Long id;
    private Long userId;
    private String category;
    private String description;
    private Double latitude;
    private Double longitude;
    private Instant createdAt;
    private String status;
    private Double confidenceScore;
}
