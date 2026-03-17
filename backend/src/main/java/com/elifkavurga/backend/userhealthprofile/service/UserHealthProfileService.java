package com.elifkavurga.backend.userhealthprofile.service;

import com.elifkavurga.backend.userhealthprofile.dto.UserHealthProfileRequest;
import com.elifkavurga.backend.userhealthprofile.dto.UserHealthProfileResponse;

public interface UserHealthProfileService {
    UserHealthProfileResponse getMe(String userIdHeader);

    UserHealthProfileResponse updateMe(String userIdHeader, UserHealthProfileRequest request);
}
