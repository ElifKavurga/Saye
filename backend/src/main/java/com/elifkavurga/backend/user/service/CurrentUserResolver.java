package com.elifkavurga.backend.user.service;

import com.elifkavurga.backend.common.exceptions.ResourceNotFoundException;
import com.elifkavurga.backend.common.exceptions.UnauthorizedException;
import com.elifkavurga.backend.user.entity.User;
import com.elifkavurga.backend.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

@Component
@RequiredArgsConstructor
public class CurrentUserResolver {

    private final UserRepository userRepository;

    @Transactional
    public User resolve(String userIdHeader) {
        if (!StringUtils.hasText(userIdHeader)) {
            throw new UnauthorizedException("X-USER-ID header is required");
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

}
