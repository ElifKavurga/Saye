package com.elifkavurga.backend.user.controller;

import com.elifkavurga.backend.common.ApiResponse;
import com.elifkavurga.backend.user.dto.CreateUserRequest;
import com.elifkavurga.backend.user.dto.UpdateMeRequest;
import com.elifkavurga.backend.user.dto.UserResponse;
import com.elifkavurga.backend.user.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @PostMapping
    public ResponseEntity<ApiResponse<UserResponse>> create(@Valid @RequestBody CreateUserRequest request) {
        UserResponse response = userService.create(request);
        return ResponseEntity.ok(ApiResponse.<UserResponse>builder()
                .success(true)
                .message("User created")
                .data(response)
                .build());
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<UserResponse>>> findAll() {
        List<UserResponse> response = userService.findAll();
        return ResponseEntity.ok(ApiResponse.<List<UserResponse>>builder()
                .success(true)
                .message("Users fetched")
                .data(response)
                .build());
    }

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<UserResponse>> getMe(
            @RequestHeader(value = "X-USER-ID", required = false) String userIdHeader
    ) {
        UserResponse response = userService.getMe(userIdHeader);
        return ResponseEntity.ok(ApiResponse.<UserResponse>builder()
                .success(true)
                .message("Current user fetched")
                .data(response)
                .build());
    }

    @PutMapping("/me")
    public ResponseEntity<ApiResponse<UserResponse>> updateMe(
            @RequestHeader(value = "X-USER-ID", required = false) String userIdHeader,
            @Valid @RequestBody UpdateMeRequest request
    ) {
        UserResponse response = userService.updateMe(userIdHeader, request);
        return ResponseEntity.ok(ApiResponse.<UserResponse>builder()
                .success(true)
                .message("Current user updated")
                .data(response)
                .build());
    }
}
