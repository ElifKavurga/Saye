package com.elifkavurga.backend.emergency.controller;

import com.elifkavurga.backend.common.ApiResponse;
import com.elifkavurga.backend.emergency.dto.EmergencyStartRequest;
import com.elifkavurga.backend.emergency.dto.EmergencyStatusResponse;
import com.elifkavurga.backend.emergency.dto.EmergencyStopRequest;
import com.elifkavurga.backend.emergency.service.EmergencyService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping({"/emergency", "/api/emergency"})
@RequiredArgsConstructor
@Tag(name = "Emergency", description = "Acil durum baslatma, durdurma ve durum sorgulama endpointleri")
public class EmergencyController {

    private final EmergencyService emergencyService;

    @PostMapping("/start")
    @Operation(
            summary = "Acil durum baslat",
            description = "Frontenddeki 'Acil durum aktif' ekranini besleyen eventi baslatir.",
            responses = {
                    @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "200", description = "Acil durum baslatildi"),
                    @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "400", description = "Kullanicinin zaten aktif bir acil durumu var")
            }
    )
    @io.swagger.v3.oas.annotations.parameters.RequestBody(
            required = true,
            content = @Content(
                    schema = @Schema(implementation = EmergencyStartRequest.class),
                    examples = @ExampleObject(
                            name = "EmergencyStart",
                            value = """
                                    {
                                      "userId": 42,
                                      "latitude": 41.0082,
                                      "longitude": 28.9784,
                                      "currentRiskLevel": "HIGH",
                                      "sharedTo": ["905551112233", "905441112233"]
                                    }
                                    """
                    )
            )
    )
    public ResponseEntity<ApiResponse<EmergencyStatusResponse>> start(@Valid @RequestBody EmergencyStartRequest request) {
        EmergencyStatusResponse response = emergencyService.start(request);
        return ResponseEntity.ok(ApiResponse.<EmergencyStatusResponse>builder()
                .success(true)
                .message("Emergency event started")
                .data(response)
                .build());
    }

    @PostMapping("/stop")
    @Operation(summary = "Acil durumu durdur")
    public ResponseEntity<ApiResponse<EmergencyStatusResponse>> stop(@Valid @RequestBody EmergencyStopRequest request) {
        EmergencyStatusResponse response = emergencyService.stop(request.getUserId());
        return ResponseEntity.ok(ApiResponse.<EmergencyStatusResponse>builder()
                .success(true)
                .message("Emergency event stopped")
                .data(response)
                .build());
    }

    @GetMapping("/status")
    @Operation(summary = "Acil durum aktif mi kontrol et")
    public ResponseEntity<ApiResponse<EmergencyStatusResponse>> status(@RequestParam Long userId) {
        EmergencyStatusResponse response = emergencyService.status(userId);
        return ResponseEntity.ok(ApiResponse.<EmergencyStatusResponse>builder()
                .success(true)
                .message("Emergency status")
                .data(response)
                .build());
    }
}
