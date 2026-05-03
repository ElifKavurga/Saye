package com.elifkavurga.backend.userhealthprofile.dto;

import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UserHealthProfileRequest {

    @Size(max = 255)
    private String bloodType;

    @Size(max = 1000)
    private String allergyNotes;

    @Size(max = 1000)
    private String emergencyNote;
}
