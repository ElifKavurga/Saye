package com.elifkavurga.backend.auth.dto;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class AuthUserResponse {
    private final Long id;
    private final String email;
    private final String username;
    private final String phone;
    private final String role;
    private final Boolean isActive;
}
