package com.elifkavurga.backend.map.dto;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class RiskResponse {
    private String level;
    private double score;
}
