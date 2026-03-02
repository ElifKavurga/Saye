package com.elifkavurga.backend.report.controller;

import com.elifkavurga.backend.common.ApiResponse;
import com.elifkavurga.backend.report.dto.ReportRequest;
import com.elifkavurga.backend.report.dto.ReportResponse;
import com.elifkavurga.backend.report.dto.ReportStatusUpdateRequest;
import com.elifkavurga.backend.report.service.ReportService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/reports")
@RequiredArgsConstructor
@Tag(name = "Reports", description = "Durum bildirme ve rapor yonetimi endpointleri")
public class ReportController {

    private final ReportService reportService;

    @PostMapping
    @Operation(
            summary = "Yeni rapor olustur",
            description = "Frontenddeki 'Bize durumu bildir' ekraninin backend karsiligidir.",
            responses = {
                    @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "200", description = "Rapor olusturuldu"),
                    @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "400", description = "Gecersiz veri")
            }
    )
    @io.swagger.v3.oas.annotations.parameters.RequestBody(
            required = true,
            content = @Content(
                    schema = @Schema(implementation = ReportRequest.class),
                    examples = @ExampleObject(
                            name = "ReportCreate",
                            value = """
                                    {
                                      "userId": 30,
                                      "category": "SUC",
                                      "description": "Parkta supheli bir durum var",
                                      "latitude": 41.0082,
                                      "longitude": 28.9784
                                    }
                                    """
                    )
            )
    )
    public ResponseEntity<ApiResponse<ReportResponse>> create(@Valid @RequestBody ReportRequest req) {
        ReportResponse resp = reportService.create(req);
        return ResponseEntity.ok(ApiResponse.<ReportResponse>builder()
                .success(true)
                .message("Report created")
                .data(resp)
                .build());
    }

    @GetMapping
    @Operation(summary = "Tum raporlari listele")
    public ResponseEntity<ApiResponse<List<ReportResponse>>> listAll() {
        List<ReportResponse> list = reportService.listAll();
        return ResponseEntity.ok(ApiResponse.<List<ReportResponse>>builder()
                .success(true)
                .message("Report list")
                .data(list)
                .build());
    }

    @GetMapping("/mine")
    @Operation(summary = "Kullanicinin kendi raporlarini getir")
    public ResponseEntity<ApiResponse<List<ReportResponse>>> listMine(@RequestParam Long userId) {
        List<ReportResponse> list = reportService.listMine(userId);
        return ResponseEntity.ok(ApiResponse.<List<ReportResponse>>builder()
                .success(true)
                .message("My report list")
                .data(list)
                .build());
    }

    @PatchMapping("/{id}/status")
    @Operation(summary = "Rapor durumunu guncelle")
    public ResponseEntity<ApiResponse<ReportResponse>> updateStatus(
            @PathVariable Long id,
            @Valid @RequestBody ReportStatusUpdateRequest req) {
        ReportResponse resp = reportService.updateStatus(id, req.getStatus(), req.getRequestedByUserId(), req.isAdmin());
        return ResponseEntity.ok(ApiResponse.<ReportResponse>builder()
                .success(true)
                .message("Report status updated")
                .data(resp)
                .build());
    }
}
