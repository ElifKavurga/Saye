package com.elifkavurga.backend.userhealthprofile.dto;

import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UserHealthProfileRequest {

    @Size(max = 32)
    private String bloodType;

    @Size(max = 2000)
    private String allergyNotes;

    @Size(max = 2000)
    private String emergencyNote;
}
