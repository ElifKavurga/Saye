package com.elifkavurga.backend.map.controller;

import com.elifkavurga.backend.map.dto.RiskResponse;
import com.elifkavurga.backend.map.service.MapService;
import com.elifkavurga.backend.report.dto.ReportResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequiredArgsConstructor
public class MapController {

    private final MapService mapService;

    @GetMapping("/map/reports")
    public ResponseEntity<List<ReportResponse>> getReports(
            @RequestParam double lat,
            @RequestParam double lng,
            @RequestParam double radius) {
        List<ReportResponse> reports = mapService.findReportsNearby(lat, lng, radius);
        return ResponseEntity.ok(reports);
    }

    @GetMapping("/risk")
    public ResponseEntity<RiskResponse> getRisk(
            @RequestParam double lat,
            @RequestParam double lng) {
        RiskResponse resp = mapService.computeRisk(lat, lng);
        return ResponseEntity.ok(resp);
    }
}
