package com.elifkavurga.backend.emergency.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class EmergencyStopRequest {
    @NotNull
    private Long userId;
}
