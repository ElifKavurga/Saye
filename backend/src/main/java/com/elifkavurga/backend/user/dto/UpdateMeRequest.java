package com.elifkavurga.backend.user.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UpdateMeRequest {
    @NotBlank
    private String username;

    private String phone;
}
