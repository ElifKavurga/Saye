package com.elifkavurga.backend.usersettings.dto;

import lombok.Builder;
import lombok.Getter;

import java.time.Instant;

@Getter
@Builder
public class UserSettingsResponse {

    private final Long id;
    private final Long userId;
    private final Boolean profileVisible;
    private final Boolean locationTrackingEnabled;
    private final Boolean backgroundRefreshEnabled;
    private final Boolean bluetoothEnabled;
    private final Boolean gsmSmsEnabled;
    private final Boolean quickUnlockAccessEnabled;
    private final Instant createdAt;
    private final Instant updatedAt;
}
