package com.elifkavurga.backend.user.service;

import com.elifkavurga.backend.common.exceptions.BadRequestException;
import com.elifkavurga.backend.user.dto.CreateUserRequest;
import com.elifkavurga.backend.user.dto.UpdateMeRequest;
import com.elifkavurga.backend.user.dto.UserResponse;
import com.elifkavurga.backend.user.entity.User;
import com.elifkavurga.backend.user.entity.UserRole;
import com.elifkavurga.backend.user.repository.UserRepository;
import com.elifkavurga.backend.userhealthprofile.entity.UserHealthProfile;
import com.elifkavurga.backend.security.EmailHashService;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.List;

@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final CurrentUserResolver currentUserResolver;
    private final EmailHashService emailHashService;

    @Override
    @Transactional
    public UserResponse create(CreateUserRequest request) {
        String email = normalizeNullable(request.getEmail());
        String username = request.getUsername().trim();
        String emailHash = emailHashService.hashEmail(email);

        if (userRepository.existsByEmailHash(emailHash)) {
            throw new BadRequestException("Email already exists");
        }
        if (userRepository.existsByUsername(username)) {
            throw new BadRequestException("Username already exists");
        }

        User user = new User();
        user.setEmail(email);
        user.setEmailHash(emailHash);
        user.setUsername(username);
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setPhone(normalizeNullable(request.getPhone()));
        user.setIsActive(true);
        user.setRole(UserRole.USER);
        user.setHealthProfile(new UserHealthProfile());

        User savedUser = userRepository.save(user);
        return toResponse(savedUser);
    }

    @Override
    public List<UserResponse> findAll() {
        return userRepository.findAll().stream().map(this::toResponse).toList();
    }

    @Override
    public UserResponse getMe(String userIdHeader) {
        return toResponse(currentUserResolver.resolve(userIdHeader));
    }

    @Override
    @Transactional
    public UserResponse updateMe(String userIdHeader, UpdateMeRequest request) {
        User user = currentUserResolver.resolve(userIdHeader);
        String username = request.getUsername().trim();
        if (userRepository.existsByUsernameAndIdNot(username, user.getId())) {
            throw new BadRequestException("Username already exists");
        }

        user.setUsername(username);
        user.setPhone(normalizeNullable(request.getPhone()));
        return toResponse(userRepository.save(user));
    }

    private String normalizeNullable(String value) {
        return StringUtils.hasText(value) ? value.trim() : null;
    }

    private UserResponse toResponse(User user) {
        return UserResponse.builder()
                .id(user.getId())
                .email(user.getEmail())
                .username(user.getUsername())
                .phone(user.getPhone())
                .role(user.getRole().name())
                .isActive(user.getIsActive())
                .createdAt(user.getCreatedAt())
                .updatedAt(user.getUpdatedAt())
                .build();
    }
}
