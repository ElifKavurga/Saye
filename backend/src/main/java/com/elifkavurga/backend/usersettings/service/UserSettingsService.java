package com.elifkavurga.backend.usersettings.service;

import com.elifkavurga.backend.usersettings.dto.UserSettingsRequest;
import com.elifkavurga.backend.usersettings.dto.UserSettingsResponse;

public interface UserSettingsService {

    UserSettingsResponse getMe(String userIdHeader);

    UserSettingsResponse updateMe(String userIdHeader, UserSettingsRequest request);
}
