package com.elifkavurga.backend.userhealthprofile.controller;

import com.elifkavurga.backend.common.ApiResponse;
import com.elifkavurga.backend.userhealthprofile.dto.UserHealthProfileRequest;
import com.elifkavurga.backend.userhealthprofile.dto.UserHealthProfileResponse;
import com.elifkavurga.backend.userhealthprofile.service.UserHealthProfileService;
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
@RequestMapping("/api/health-profile")
@RequiredArgsConstructor
public class UserHealthProfileController {

    private final UserHealthProfileService userHealthProfileService;

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<UserHealthProfileResponse>> getMe(
            @RequestHeader(value = "X-USER-ID", required = false) String userIdHeader
    ) {
        UserHealthProfileResponse response = userHealthProfileService.getMe(userIdHeader);
        return ResponseEntity.ok(ApiResponse.<UserHealthProfileResponse>builder()
                .success(true)
                .message("Health profile fetched")
                .data(response)
                .build());
    }

    @PutMapping("/me")
    public ResponseEntity<ApiResponse<UserHealthProfileResponse>> updateMe(
            @RequestHeader(value = "X-USER-ID", required = false) String userIdHeader,
            @Valid @RequestBody UserHealthProfileRequest request
    ) {
        UserHealthProfileResponse response = userHealthProfileService.updateMe(userIdHeader, request);
        return ResponseEntity.ok(ApiResponse.<UserHealthProfileResponse>builder()
                .success(true)
                .message("Health profile updated")
                .data(response)
                .build());
    }
}
