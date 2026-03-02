package com.elifkavurga.backend.emergency.dto;

import lombok.Builder;
import lombok.Getter;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Schema;

import java.time.Instant;
import java.util.List;

@Getter
@Builder
@Schema(description = "Acil durum durum cevabi")
public class EmergencyStatusResponse {
    @Schema(example = "5")
    private Long id;
    @Schema(example = "42")
    private Long userId;
    @Schema(example = "2026-03-02T09:20:00Z")
    private Instant startedAt;
    @Schema(example = "2026-03-02T09:32:00Z")
    private Instant endedAt;
    @Schema(example = "41.0082")
    private Double latitude;
    @Schema(example = "28.9784")
    private Double longitude;
    @Schema(example = "true")
    private boolean active;
    @ArraySchema(schema = @Schema(example = "905551112233"))
    private List<String> sharedTo;
}
