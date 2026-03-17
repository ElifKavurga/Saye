package com.elifkavurga.backend.emergencycontact.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class EmergencyContactRequest {

    @NotBlank
    private String name;

    @NotBlank
    private String phoneNumber;

    private Boolean isPrimary = false;
}
