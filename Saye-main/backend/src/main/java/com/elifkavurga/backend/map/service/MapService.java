package com.elifkavurga.backend.map.service;

import com.elifkavurga.backend.map.dto.RiskResponse;
import com.elifkavurga.backend.report.dto.ReportResponse;

import java.util.List;

public interface MapService {
    List<ReportResponse> findReportsNearby(double lat, double lng, double radiusMeters);
    RiskResponse computeRisk(double lat, double lng);
}
