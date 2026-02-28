package com.elifkavurga.backend.report.controller;

import com.elifkavurga.backend.common.ApiResponse;
import com.elifkavurga.backend.report.dto.ReportRequest;
import com.elifkavurga.backend.report.dto.ReportResponse;
import com.elifkavurga.backend.report.service.ReportService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/reports")
@RequiredArgsConstructor
public class ReportController {

    private final ReportService reportService;

    @PostMapping
    public ResponseEntity<ApiResponse<ReportResponse>> create(@Valid @RequestBody ReportRequest req) {
        ReportResponse resp = reportService.create(req);
        return ResponseEntity.ok(ApiResponse.<ReportResponse>builder()
                .success(true)
                .message("Report created")
                .data(resp)
                .build());
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<ReportResponse>>> listAll() {
        List<ReportResponse> list = reportService.listAll();
        return ResponseEntity.ok(ApiResponse.<List<ReportResponse>>builder()
                .success(true)
                .message("Report list")
                .data(list)
                .build());
    }
}
