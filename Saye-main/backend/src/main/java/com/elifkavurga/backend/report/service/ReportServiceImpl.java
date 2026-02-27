package com.elifkavurga.backend.report.service;

import com.elifkavurga.backend.report.dto.ReportRequest;
import com.elifkavurga.backend.report.dto.ReportResponse;
import com.elifkavurga.backend.report.entity.Report;
import com.elifkavurga.backend.report.entity.ReportCategory;
import com.elifkavurga.backend.report.repository.ReportRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ReportServiceImpl implements ReportService {

    private final ReportRepository repository;

    @Override
    public ReportResponse create(ReportRequest request) {
        Report report = new Report();
        report.setUserId(request.getUserId());
        report.setCategory(Enum.valueOf(ReportCategory.class, request.getCategory()));
        report.setDescription(request.getDescription());
        report.setLatitude(request.getLatitude());
        report.setLongitude(request.getLongitude());
        report = repository.save(report);
        return toResponse(report);
    }

    @Override
    public List<ReportResponse> listAll() {
        return repository.findAll().stream().map(this::toResponse).collect(Collectors.toList());
    }

    private ReportResponse toResponse(Report r) {
        return ReportResponse.builder()
                .id(r.getId())
                .userId(r.getUserId())
                .category(r.getCategory().name())
                .description(r.getDescription())
                .latitude(r.getLatitude())
                .longitude(r.getLongitude())
                .createdAt(r.getCreatedAt())
                .status(r.getStatus().name())
                .confidenceScore(r.getConfidenceScore())
                .build();
    }
}
