package com.elifkavurga.backend.usersettings.service;

import com.elifkavurga.backend.common.exceptions.ResourceNotFoundException;
import com.elifkavurga.backend.common.exceptions.UnauthorizedException;
import com.elifkavurga.backend.config.AppSecurityProperties;
import com.elifkavurga.backend.user.entity.User;
import com.elifkavurga.backend.user.entity.UserRole;
import com.elifkavurga.backend.user.repository.UserRepository;
import com.elifkavurga.backend.usersettings.dto.UserSettingsRequest;
import com.elifkavurga.backend.usersettings.dto.UserSettingsResponse;
import com.elifkavurga.backend.usersettings.entity.UserSettings;
import com.elifkavurga.backend.usersettings.repository.UserSettingsRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

@Service
@RequiredArgsConstructor
public class UserSettingsServiceImpl implements UserSettingsService {

    private static final String DEMO_EMAIL = "demo@example.com";
    private static final String DEMO_PASSWORD = "demo12345";
    private static final String DEMO_USERNAME = "demo-user";

    private final UserSettingsRepository userSettingsRepository;
    private final UserRepository userRepository;
    private final AppSecurityProperties appSecurityProperties;
    private final PasswordEncoder passwordEncoder;

    @Override
    @Transactional
    public UserSettingsResponse getMe(String userIdHeader) {
        User currentUser = resolveCurrentUser(userIdHeader);
        return toResponse(getOrCreateSettings(currentUser.getId()));
    }

    @Override
    @Transactional
    public UserSettingsResponse updateMe(String userIdHeader, UserSettingsRequest request) {
        User currentUser = resolveCurrentUser(userIdHeader);
        UserSettings settings = getOrCreateSettings(currentUser.getId());
        settings.setProfileVisible(request.getProfileVisible());
        settings.setLocationTrackingEnabled(request.getLocationTrackingEnabled());
        settings.setBackgroundRefreshEnabled(request.getBackgroundRefreshEnabled());
        return toResponse(userSettingsRepository.save(settings));
    }

    private UserSettings getOrCreateSettings(Long userId) {
        return userSettingsRepository.findByUserId(userId)
                .orElseGet(() -> userSettingsRepository.save(createDefaultSettings(userId)));
    }

    private UserSettings createDefaultSettings(Long userId) {
        UserSettings settings = new UserSettings();
        settings.setUserId(userId);
        settings.setProfileVisible(true);
        settings.setLocationTrackingEnabled(true);
        settings.setBackgroundRefreshEnabled(true);
        return settings;
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
                .orElseThrow(() -> new ResourceNotFoundException("User not found for X-USER-ID: " + userId));
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

    private UserSettingsResponse toResponse(UserSettings settings) {
        return UserSettingsResponse.builder()
                .id(settings.getId())
                .userId(settings.getUserId())
                .profileVisible(settings.getProfileVisible())
                .locationTrackingEnabled(settings.getLocationTrackingEnabled())
                .backgroundRefreshEnabled(settings.getBackgroundRefreshEnabled())
                .createdAt(settings.getCreatedAt())
                .updatedAt(settings.getUpdatedAt())
                .build();
    }
}
