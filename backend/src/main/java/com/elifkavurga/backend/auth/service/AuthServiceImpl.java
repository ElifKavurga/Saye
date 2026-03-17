package com.elifkavurga.backend.auth.service;

import com.elifkavurga.backend.auth.dto.AuthResponse;
import com.elifkavurga.backend.auth.dto.AuthUserResponse;
import com.elifkavurga.backend.auth.dto.LoginRequest;
import com.elifkavurga.backend.auth.dto.RegisterRequest;
import com.elifkavurga.backend.common.exceptions.BadRequestException;
import com.elifkavurga.backend.config.AppSecurityProperties;
import com.elifkavurga.backend.user.entity.User;
import com.elifkavurga.backend.user.repository.UserRepository;
import com.elifkavurga.backend.user.service.CurrentUserResolver;
import com.elifkavurga.backend.userhealthprofile.entity.UserHealthProfile;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

    private final AppSecurityProperties appSecurityProperties;
    private final UserRepository userRepository;
    private final BCryptPasswordEncoder passwordEncoder;
    private final TokenService tokenService;
    private final CurrentUserResolver currentUserResolver;

    @Override
    public AuthResponse register(RegisterRequest registerRequest) {
        String email = registerRequest.getEmail().trim();
        String username = registerRequest.getUsername().trim();

        if (userRepository.existsByEmail(email)) {
            throw new BadRequestException("Email already exists");
        }
        if (userRepository.existsByUsername(username)) {
            throw new BadRequestException("Username already exists");
        }

        User user = new User();
        user.setEmail(email);
        user.setUsername(username);
        user.setPassword(passwordEncoder.encode(registerRequest.getPassword()));
        user.setPhone(normalizeNullable(registerRequest.getPhone()));
        user.setHealthProfile(new UserHealthProfile());

        User savedUser = userRepository.save(user);
        return toAuthResponse(savedUser);
    }

    @Override
    public AuthResponse login(LoginRequest loginRequest) {
        User user = userRepository.findByEmail(loginRequest.getEmail())
                .orElseThrow(() -> new BadRequestException("Invalid credentials"));

        if (!passwordEncoder.matches(loginRequest.getPassword(), user.getPassword())) {
            throw new BadRequestException("Invalid credentials");
        }

        return toAuthResponse(user);
    }

    @Override
    public AuthResponse demoLogin() {
        if (!appSecurityProperties.isDemoLoginEnabled()) {
            throw new BadRequestException("Demo login is disabled");
        }
        return toAuthResponse(currentUserResolver.getOrCreateDemoUser());
    }

    @Override
    public AuthResponse refresh(String refreshToken) {
        Long userId = tokenService.validateRefreshToken(refreshToken);
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new BadRequestException("User not found"));
        return toAuthResponse(user);
    }

    private AuthResponse toAuthResponse(User user) {
        return AuthResponse.builder()
                .token(tokenService.issueAccessToken(user))
                .refreshToken(tokenService.issueRefreshToken(user))
                .user(AuthUserResponse.builder()
                        .id(user.getId())
                        .email(user.getEmail())
                        .username(user.getUsername())
                        .phone(user.getPhone())
                        .build())
                .build();
    }

    private String normalizeNullable(String value) {
        return StringUtils.hasText(value) ? value.trim() : null;
    }
}
