package com.elifkavurga.backend.report.service;

import com.elifkavurga.backend.report.dto.ReportRequest;
import com.elifkavurga.backend.report.dto.ReportResponse;
import com.elifkavurga.backend.report.entity.Report;
import com.elifkavurga.backend.report.entity.ReportCategory;
import com.elifkavurga.backend.report.entity.ReportStatus;
import com.elifkavurga.backend.report.repository.ReportRepository;
import lombok.RequiredArgsConstructor;
import org.locationtech.jts.geom.Coordinate;
import org.locationtech.jts.geom.GeometryFactory;
import org.locationtech.jts.geom.Point;
import org.locationtech.jts.geom.PrecisionModel;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ReportServiceImpl implements ReportService {

    private final ReportRepository repository;

    @Override
    public ReportResponse create(ReportRequest request) {
        ReportCategory category = Enum.valueOf(ReportCategory.class, request.getCategory());

        Point point = null;
        if (request.getLatitude() != null && request.getLongitude() != null) {
            GeometryFactory gf = new GeometryFactory(new PrecisionModel(), 4326);
            point = gf.createPoint(new Coordinate(request.getLongitude(), request.getLatitude()));
            Optional<Report> existing = repository.findActiveReportByCategoryNear(point, 50.0, category.name());
            if (existing.isPresent()) {
                Report report = existing.get();
                report.setUpdatedAt(Instant.now());
                report = repository.save(report);
                return toResponse(report);
            }
        }

        Report report = new Report();
        report.setUserId(request.getUserId());
        report.setCategory(category);
        report.setDescription(request.getDescription());
        if (point != null) {
            report.setLocation(point);
        }
        report = repository.save(report);
        return toResponse(report);
    }

    @Override
    public List<ReportResponse> listAll() {
        return repository.findAll().stream().map(this::toResponse).collect(Collectors.toList());
    }

    @Override
    public List<ReportResponse> listMine(Long userId) {
        if (userId == null) {
            throw new IllegalArgumentException("userId zorunlu");
        }
        return repository.findAllByUserIdOrderByCreatedAtDesc(userId).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    public ReportResponse updateStatus(Long reportId, String status, Long requestedByUserId, boolean admin) {
        if (status == null || status.isBlank()) {
            throw new IllegalArgumentException("status zorunlu");
        }

        Report report = repository.findById(reportId)
                .orElseThrow(() -> new IllegalArgumentException("Rapor bulunamadi"));

        boolean owner = requestedByUserId != null && requestedByUserId.equals(report.getUserId());
        if (!admin && !owner) {
            throw new IllegalArgumentException("Bu raporun durumunu guncelleme yetkin yok");
        }

        report.setStatus(ReportStatus.valueOf(status.trim().toUpperCase()));
        report = repository.save(report);
        return toResponse(report);
    }

    private ReportResponse toResponse(Report r) {
        return ReportResponse.builder()
                .id(r.getId())
                .userId(r.getUserId())
                .category(r.getCategory() != null ? r.getCategory().name() : null)
                .description(r.getDescription())
                .latitude(r.getLatitude())
                .longitude(r.getLongitude())
                .createdAt(r.getCreatedAt())
                .status(r.getStatus() != null ? r.getStatus().name() : null)
                .confidenceScore(r.getConfidenceScore())
                .build();
    }
}
