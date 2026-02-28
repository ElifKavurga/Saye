package com.elifkavurga.backend.report.service;

import com.elifkavurga.backend.report.dto.ReportRequest;
import com.elifkavurga.backend.report.dto.ReportResponse;

import java.util.List;

public interface ReportService {
    ReportResponse create(ReportRequest request);
    List<ReportResponse> listAll();
}
