package com.elifkavurga.backend.user.service;

import com.elifkavurga.backend.common.exceptions.ResourceNotFoundException;
import com.elifkavurga.backend.common.exceptions.UnauthorizedException;
import com.elifkavurga.backend.config.AppSecurityProperties;
import com.elifkavurga.backend.user.entity.User;
import com.elifkavurga.backend.user.repository.UserRepository;
import com.elifkavurga.backend.userhealthprofile.entity.UserHealthProfile;
import com.elifkavurga.backend.security.EmailHashService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

@Component
@RequiredArgsConstructor
public class CurrentUserResolver {

    private static final String DEMO_EMAIL = "demo@example.com";
    private static final String DEMO_PASSWORD = "demo12345";
    private static final String DEMO_USERNAME = "demo-user";

    private final UserRepository userRepository;
    private final AppSecurityProperties appSecurityProperties;
    private final PasswordEncoder passwordEncoder;
    private final EmailHashService emailHashService;

    @Transactional
    public User resolve(String userIdHeader) {
        if (!StringUtils.hasText(userIdHeader)) {
            return getOrCreateDemoUser();
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

    @Transactional
    public User getOrCreateDemoUser() {
        if (!appSecurityProperties.isDemoLoginEnabled()) {
            throw new UnauthorizedException("X-USER-ID header is required");
        }

        return userRepository.findByEmailHash(emailHashService.hashEmail(DEMO_EMAIL))
                .orElseGet(this::createDemoUser);
    }

    private User createDemoUser() {
        User user = new User();
        user.setEmail(DEMO_EMAIL);
        user.setUsername(DEMO_USERNAME);
        user.setPassword(passwordEncoder.encode(DEMO_PASSWORD));
        user.setPhone(null);
        user.setEmailHash(emailHashService.hashEmail(DEMO_EMAIL));
        user.setHealthProfile(new UserHealthProfile());
        return userRepository.save(user);
    }
}
