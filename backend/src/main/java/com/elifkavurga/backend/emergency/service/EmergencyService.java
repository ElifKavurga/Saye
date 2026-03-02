package com.elifkavurga.backend.emergency.service;

import com.elifkavurga.backend.emergency.dto.EmergencyStartRequest;
import com.elifkavurga.backend.emergency.dto.EmergencyStatusResponse;

public interface EmergencyService {
    EmergencyStatusResponse start(EmergencyStartRequest request);
    EmergencyStatusResponse stop(Long userId);
    EmergencyStatusResponse status(Long userId);
}
