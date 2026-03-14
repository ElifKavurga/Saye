package com.elifkavurga.backend.emergencycontact.service;

import com.elifkavurga.backend.emergencycontact.dto.EmergencyContactRequest;
import com.elifkavurga.backend.emergencycontact.dto.EmergencyContactResponse;

import java.util.List;

public interface EmergencyContactService {

    List<EmergencyContactResponse> listMine(String userIdHeader);

    EmergencyContactResponse create(String userIdHeader, EmergencyContactRequest request);

    EmergencyContactResponse update(String userIdHeader, Long contactId, EmergencyContactRequest request);

    void delete(String userIdHeader, Long contactId);
}
