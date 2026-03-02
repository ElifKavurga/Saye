package com.elifkavurga.backend.map.dto;

import lombok.Builder;
import lombok.EqualsAndHashCode;
import lombok.Getter;

@Getter
@Builder
@EqualsAndHashCode
public class RiskResponse {
    private String level;
    private double score;
}
