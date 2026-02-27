package com.elifkavurga.backend.report.dto;

import lombok.Getter;
import lombok.Setter;

import jakarta.validation.constraints.NotNull;
import java.io.Serializable;

@Getter
@Setter
public class ReportRequest implements Serializable {
    // user id optional
    private Long userId;

    @NotNull
    private String category;

    private String description;

    private Double latitude;
    private Double longitude;
}
