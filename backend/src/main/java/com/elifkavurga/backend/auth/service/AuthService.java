package com.elifkavurga.backend.auth.service;

import com.elifkavurga.backend.auth.dto.AuthResponse;
import com.elifkavurga.backend.auth.dto.LoginRequest;
import com.elifkavurga.backend.auth.dto.RegisterRequest;

public interface AuthService {
    AuthResponse register(RegisterRequest registerRequest);

    AuthResponse login(LoginRequest loginRequest);

    AuthResponse demoLogin();
}
