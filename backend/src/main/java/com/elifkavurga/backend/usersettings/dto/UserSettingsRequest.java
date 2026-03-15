package com.elifkavurga.backend.usersettings.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UserSettingsRequest {

    @NotNull
    private Boolean profileVisible;

    @NotNull
    private Boolean locationTrackingEnabled;

    @NotNull
    private Boolean backgroundRefreshEnabled;

    @NotNull
    private Boolean bluetoothEnabled;

    @NotNull
    private Boolean gsmSmsEnabled;

    @NotNull
    private Boolean quickUnlockAccessEnabled;
}
