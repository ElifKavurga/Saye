package com.elifkavurga.backend.user.dto;

import lombok.Builder;
import lombok.Getter;

import java.time.Instant;

@Getter
@Builder
public class UserResponse {
    private final Long id;
    private final String email;
    private final String username;
    private final String phone;
    private final String role;
    private final Boolean isActive;
    private final Instant createdAt;
    private final Instant updatedAt;
}
