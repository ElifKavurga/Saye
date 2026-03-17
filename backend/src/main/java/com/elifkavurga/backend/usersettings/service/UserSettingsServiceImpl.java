package com.elifkavurga.backend.usersettings.service;

import com.elifkavurga.backend.user.entity.User;
import com.elifkavurga.backend.user.service.CurrentUserResolver;
import com.elifkavurga.backend.usersettings.dto.UserSettingsRequest;
import com.elifkavurga.backend.usersettings.dto.UserSettingsResponse;
import com.elifkavurga.backend.usersettings.entity.UserSettings;
import com.elifkavurga.backend.usersettings.repository.UserSettingsRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class UserSettingsServiceImpl implements UserSettingsService {

    private final UserSettingsRepository userSettingsRepository;
    private final CurrentUserResolver currentUserResolver;

    @Override
    @Transactional
    public UserSettingsResponse getMe(String userIdHeader) {
        User currentUser = currentUserResolver.resolve(userIdHeader);
        return toResponse(getOrCreateSettings(currentUser.getId()));
    }

    @Override
    @Transactional
    public UserSettingsResponse updateMe(String userIdHeader, UserSettingsRequest request) {
        User currentUser = currentUserResolver.resolve(userIdHeader);
        UserSettings settings = getOrCreateSettings(currentUser.getId());
        settings.setProfileVisible(request.getProfileVisible());
        settings.setLocationTrackingEnabled(request.getLocationTrackingEnabled());
        settings.setBackgroundRefreshEnabled(request.getBackgroundRefreshEnabled());
        settings.setBluetoothEnabled(request.getBluetoothEnabled());
        settings.setGsmSmsEnabled(request.getGsmSmsEnabled());
        settings.setQuickUnlockAccessEnabled(request.getQuickUnlockAccessEnabled());
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
        settings.setBluetoothEnabled(true);
        settings.setGsmSmsEnabled(false);
        settings.setQuickUnlockAccessEnabled(false);
        return settings;
    }

    private UserSettingsResponse toResponse(UserSettings settings) {
        return UserSettingsResponse.builder()
                .id(settings.getId())
                .userId(settings.getUserId())
                .profileVisible(settings.getProfileVisible())
                .locationTrackingEnabled(settings.getLocationTrackingEnabled())
                .backgroundRefreshEnabled(settings.getBackgroundRefreshEnabled())
                .bluetoothEnabled(settings.getBluetoothEnabled())
                .gsmSmsEnabled(settings.getGsmSmsEnabled())
                .quickUnlockAccessEnabled(settings.getQuickUnlockAccessEnabled())
                .createdAt(settings.getCreatedAt())
                .updatedAt(settings.getUpdatedAt())
                .build();
    }
}
