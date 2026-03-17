package com.elifkavurga.backend.userhealthprofile.dto;

import lombok.Builder;
import lombok.Getter;

import java.time.Instant;

@Getter
@Builder
public class UserHealthProfileResponse {
    private final Long id;
    private final Long userId;
    private final String bloodType;
    private final String allergyNotes;
    private final String emergencyNote;
    private final Instant createdAt;
    private final Instant updatedAt;
}
