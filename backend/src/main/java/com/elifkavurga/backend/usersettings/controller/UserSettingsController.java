package com.elifkavurga.backend.usersettings.controller;

import com.elifkavurga.backend.common.ApiResponse;
import com.elifkavurga.backend.usersettings.dto.UserSettingsRequest;
import com.elifkavurga.backend.usersettings.dto.UserSettingsResponse;
import com.elifkavurga.backend.usersettings.service.UserSettingsService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/settings")
@RequiredArgsConstructor
public class UserSettingsController {

    private final UserSettingsService userSettingsService;

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<UserSettingsResponse>> getMe(
            @RequestHeader(value = "X-USER-ID", required = false) String userIdHeader
    ) {
        UserSettingsResponse response = userSettingsService.getMe(userIdHeader);
        return ResponseEntity.ok(ApiResponse.<UserSettingsResponse>builder()
                .success(true)
                .message("User settings fetched")
                .data(response)
                .build());
    }

    @PutMapping("/me")
    public ResponseEntity<ApiResponse<UserSettingsResponse>> updateMe(
            @RequestHeader(value = "X-USER-ID", required = false) String userIdHeader,
            @Valid @RequestBody UserSettingsRequest request
    ) {
        UserSettingsResponse response = userSettingsService.updateMe(userIdHeader, request);
        return ResponseEntity.ok(ApiResponse.<UserSettingsResponse>builder()
                .success(true)
                .message("User settings updated")
                .data(response)
                .build());
    }
}
