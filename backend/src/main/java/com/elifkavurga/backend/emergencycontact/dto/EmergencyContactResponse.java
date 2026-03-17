package com.elifkavurga.backend.emergencycontact.dto;

import lombok.Builder;
import lombok.Getter;

import java.time.Instant;

@Getter
@Builder
public class EmergencyContactResponse {

    private final Long id;
    private final Long userId;
    private final String name;
    private final String phoneNumber;
    private final Boolean isPrimary;
    private final Instant createdAt;
    private final Instant updatedAt;
}
