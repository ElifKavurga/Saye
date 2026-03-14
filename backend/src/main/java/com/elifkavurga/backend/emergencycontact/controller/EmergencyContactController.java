package com.elifkavurga.backend.emergencycontact.controller;

import com.elifkavurga.backend.common.ApiResponse;
import com.elifkavurga.backend.emergencycontact.dto.EmergencyContactRequest;
import com.elifkavurga.backend.emergencycontact.dto.EmergencyContactResponse;
import com.elifkavurga.backend.emergencycontact.service.EmergencyContactService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/emergency-contacts")
@RequiredArgsConstructor
public class EmergencyContactController {

    private final EmergencyContactService emergencyContactService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<EmergencyContactResponse>>> listMine(
            @RequestHeader(value = "X-USER-ID", required = false) String userIdHeader
    ) {
        List<EmergencyContactResponse> response = emergencyContactService.listMine(userIdHeader);
        return ResponseEntity.ok(ApiResponse.<List<EmergencyContactResponse>>builder()
                .success(true)
                .message("Emergency contacts fetched")
                .data(response)
                .build());
    }

    @PostMapping
    public ResponseEntity<ApiResponse<EmergencyContactResponse>> create(
            @RequestHeader(value = "X-USER-ID", required = false) String userIdHeader,
            @Valid @RequestBody EmergencyContactRequest request
    ) {
        EmergencyContactResponse response = emergencyContactService.create(userIdHeader, request);
        return ResponseEntity.ok(ApiResponse.<EmergencyContactResponse>builder()
                .success(true)
                .message("Emergency contact created")
                .data(response)
                .build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<EmergencyContactResponse>> update(
            @RequestHeader(value = "X-USER-ID", required = false) String userIdHeader,
            @PathVariable Long id,
            @Valid @RequestBody EmergencyContactRequest request
    ) {
        EmergencyContactResponse response = emergencyContactService.update(userIdHeader, id, request);
        return ResponseEntity.ok(ApiResponse.<EmergencyContactResponse>builder()
                .success(true)
                .message("Emergency contact updated")
                .data(response)
                .build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> delete(
            @RequestHeader(value = "X-USER-ID", required = false) String userIdHeader,
            @PathVariable Long id
    ) {
        emergencyContactService.delete(userIdHeader, id);
        return ResponseEntity.ok(ApiResponse.<Void>builder()
                .success(true)
                .message("Emergency contact deleted")
                .data(null)
                .build());
    }
}
