package com.elifkavurga.backend.userhealthprofile.service;

import com.elifkavurga.backend.user.entity.User;
import com.elifkavurga.backend.user.service.CurrentUserResolver;
import com.elifkavurga.backend.userhealthprofile.dto.UserHealthProfileRequest;
import com.elifkavurga.backend.userhealthprofile.dto.UserHealthProfileResponse;
import com.elifkavurga.backend.userhealthprofile.entity.UserHealthProfile;
import com.elifkavurga.backend.userhealthprofile.repository.UserHealthProfileRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

@Service
@RequiredArgsConstructor
public class UserHealthProfileServiceImpl implements UserHealthProfileService {

    private final UserHealthProfileRepository userHealthProfileRepository;
    private final CurrentUserResolver currentUserResolver;

    @Override
    @Transactional
    public UserHealthProfileResponse getMe(String userIdHeader) {
        User currentUser = currentUserResolver.resolve(userIdHeader);
        return toResponse(getOrCreateProfile(currentUser));
    }

    @Override
    @Transactional
    public UserHealthProfileResponse updateMe(String userIdHeader, UserHealthProfileRequest request) {
        User currentUser = currentUserResolver.resolve(userIdHeader);
        UserHealthProfile profile = userHealthProfileRepository.findByUser_Id(currentUser.getId())
                .orElseGet(() -> createProfile(currentUser));
        profile.setBloodType(normalizeNullable(request.getBloodType()));
        profile.setAllergyNotes(normalizeNullable(request.getAllergyNotes()));
        profile.setEmergencyNote(normalizeNullable(request.getEmergencyNote()));
        return toResponse(userHealthProfileRepository.save(profile));
    }

    private UserHealthProfile getOrCreateProfile(User user) {
        return userHealthProfileRepository.findByUser_Id(user.getId())
                .orElseGet(() -> createProfile(user));
    }

    private UserHealthProfile createProfile(User user) {
        UserHealthProfile profile = new UserHealthProfile();
        user.setHealthProfile(profile);
        return userHealthProfileRepository.save(profile);
    }

    private String normalizeNullable(String value) {
        return StringUtils.hasText(value) ? value.trim() : null;
    }

    private UserHealthProfileResponse toResponse(UserHealthProfile profile) {
        return UserHealthProfileResponse.builder()
                .id(profile.getId())
                .userId(profile.getUser().getId())
                .bloodType(profile.getBloodType())
                .allergyNotes(profile.getAllergyNotes())
                .emergencyNote(profile.getEmergencyNote())
                .createdAt(profile.getCreatedAt())
                .updatedAt(profile.getUpdatedAt())
                .build();
    }
}
