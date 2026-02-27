package com.elifkavurga.backend.user.service;

import com.elifkavurga.backend.user.dto.CreateUserRequest;
import com.elifkavurga.backend.user.dto.UpdateMeRequest;
import com.elifkavurga.backend.user.dto.UserResponse;

import java.util.List;

public interface UserService {
    UserResponse create(CreateUserRequest request);

    List<UserResponse> findAll();

    UserResponse getMe(String userIdHeader);

    UserResponse updateMe(String userIdHeader, UpdateMeRequest request);
}
