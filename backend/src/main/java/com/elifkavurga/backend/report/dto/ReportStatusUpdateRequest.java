package com.elifkavurga.backend.report.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ReportStatusUpdateRequest {
    @NotBlank
    private String status;

    private Long requestedByUserId;

    private boolean admin;
}
