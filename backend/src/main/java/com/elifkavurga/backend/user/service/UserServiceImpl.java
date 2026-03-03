package com.elifkavurga.backend.user.service;

import com.elifkavurga.backend.common.exceptions.BadRequestException;
import com.elifkavurga.backend.common.exceptions.UnauthorizedException;
import com.elifkavurga.backend.config.AppSecurityProperties;
import com.elifkavurga.backend.user.dto.CreateUserRequest;
import com.elifkavurga.backend.user.dto.UpdateMeRequest;
import com.elifkavurga.backend.user.dto.UserResponse;
import com.elifkavurga.backend.user.entity.User;
import com.elifkavurga.backend.user.entity.UserRole;
import com.elifkavurga.backend.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.List;

@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private static final String DEMO_EMAIL = "demo@example.com";
    private static final String DEMO_PASSWORD = "demo12345";
    private static final String DEMO_USERNAME = "demo-user";

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final AppSecurityProperties appSecurityProperties;

    @Override
    public UserResponse create(CreateUserRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new BadRequestException("Email already exists");
        }

        User user = new User();
        user.setUsername(request.getUsername());
        user.setFirstName(request.getUsername());
        user.setLastName("-");
        user.setRole(UserRole.USER);
        user.setEmail(request.getEmail());
        String encodedPassword = passwordEncoder.encode(request.getPassword());
        user.setPasswordHash(encodedPassword);
        user.setPassword(encodedPassword);
        user.setPhone(request.getPhone());
        user.setIsActive(true);

        User savedUser = userRepository.save(user);
        return toResponse(savedUser);
    }

    @Override
    public List<UserResponse> findAll() {
        return userRepository.findAll().stream().map(this::toResponse).toList();
    }

    @Override
    public UserResponse getMe(String userIdHeader) {
        return toResponse(resolveCurrentUser(userIdHeader));
    }

    @Override
    public UserResponse updateMe(String userIdHeader, UpdateMeRequest request) {
        User user = resolveCurrentUser(userIdHeader);
        user.setUsername(request.getUsername());
        user.setFirstName(request.getUsername());
        user.setPhone(request.getPhone());
        return toResponse(userRepository.save(user));
    }

    private User resolveCurrentUser(String userIdHeader) {
        if (!StringUtils.hasText(userIdHeader)) {
            if (!appSecurityProperties.isDemoLoginEnabled()) {
                throw new UnauthorizedException("X-USER-ID header is required");
            }
            return userRepository.findByEmail(DEMO_EMAIL).orElseGet(this::createDemoUser);
        }

        Long userId;
        try {
            userId = Long.parseLong(userIdHeader);
        } catch (NumberFormatException ex) {
            throw new IllegalArgumentException("X-USER-ID must be a valid number");
        }

        return userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found for X-USER-ID: " + userId));
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

    private UserResponse toResponse(User user) {
        return UserResponse.builder()
                .id(user.getId())
                .email(user.getEmail())
                .username(user.getUsername())
                .phone(user.getPhone())
                .isActive(user.getIsActive())
                .createdAt(user.getCreatedAt())
                .updatedAt(user.getUpdatedAt())
                .build();
    }
}
