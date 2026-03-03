package com.elifkavurga.backend.auth.service;

import com.elifkavurga.backend.auth.dto.AuthResponse;
import com.elifkavurga.backend.auth.dto.AuthUserResponse;
import com.elifkavurga.backend.auth.dto.LoginRequest;
import com.elifkavurga.backend.auth.dto.RegisterRequest;
import com.elifkavurga.backend.common.exceptions.BadRequestException;
import com.elifkavurga.backend.config.AppSecurityProperties;
import com.elifkavurga.backend.user.entity.User;
import com.elifkavurga.backend.user.entity.UserRole;
import com.elifkavurga.backend.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

    private static final String DEMO_EMAIL = "demo@example.com";
    private static final String DEMO_PASSWORD = "demo12345";
    private static final String DEMO_USERNAME = "demo-user";

    private final AppSecurityProperties appSecurityProperties;
    private final UserRepository userRepository;
    private final BCryptPasswordEncoder passwordEncoder;
    private final TokenService tokenService;

    @Override
    public AuthResponse register(RegisterRequest registerRequest) {
        if (userRepository.existsByEmail(registerRequest.getEmail())) {
            throw new BadRequestException("Email already exists");
        }

        User user = new User();
        user.setEmail(registerRequest.getEmail());
        user.setUsername(registerRequest.getUsername());
        user.setFirstName(registerRequest.getUsername());
        user.setLastName("-");
        user.setRole(UserRole.USER);
        String encodedPassword = passwordEncoder.encode(registerRequest.getPassword());
        user.setPasswordHash(encodedPassword);
        user.setPassword(encodedPassword);
        user.setPhone(registerRequest.getPhone());
        user.setIsActive(true);

        User savedUser = userRepository.save(user);
        return toAuthResponse(savedUser);
    }

    @Override
    public AuthResponse login(LoginRequest loginRequest) {
        User user = userRepository.findByEmail(loginRequest.getEmail())
                .orElseThrow(() -> new BadRequestException("Invalid credentials"));

        if (!passwordEncoder.matches(loginRequest.getPassword(), user.getPasswordHash())) {
            throw new BadRequestException("Invalid credentials");
        }

        return toAuthResponse(user);
    }

    @Override
    public AuthResponse demoLogin() {
        if (!appSecurityProperties.isDemoLoginEnabled()) {
            throw new BadRequestException("Demo login is disabled");
        }

        User demoUser = userRepository.findByEmail(DEMO_EMAIL).orElseGet(this::createDemoUser);
        return toAuthResponse(demoUser);
    }

    private User createDemoUser() {
        User user = new User();
        user.setEmail(DEMO_EMAIL);
        user.setUsername(DEMO_USERNAME);
        user.setFirstName(DEMO_USERNAME);
        user.setLastName("-");
        user.setRole(UserRole.USER);
        String encodedPassword = passwordEncoder.encode(DEMO_PASSWORD);
        user.setPasswordHash(encodedPassword);
        user.setPassword(encodedPassword);
        user.setPhone(null);
        user.setIsActive(true);
        return userRepository.save(user);
    }

    private AuthResponse toAuthResponse(User user) {
        return AuthResponse.builder()
                .token(tokenService.issueToken(user))
                .user(AuthUserResponse.builder()
                        .id(user.getId())
                        .email(user.getEmail())
                        .username(user.getUsername())
                        .phone(user.getPhone())
                        .build())
                .build();
    }
}
