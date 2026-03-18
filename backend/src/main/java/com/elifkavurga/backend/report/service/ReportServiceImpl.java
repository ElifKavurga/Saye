package com.elifkavurga.backend.report.service;

import com.elifkavurga.backend.report.dto.ReportRequest;
import com.elifkavurga.backend.report.dto.ReportResponse;
import com.elifkavurga.backend.report.entity.Report;
import com.elifkavurga.backend.report.entity.ReportCategory;
import com.elifkavurga.backend.report.entity.ReportStatus;
import com.elifkavurga.backend.report.repository.ReportRepository;
import com.elifkavurga.backend.user.entity.User;
import com.elifkavurga.backend.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.locationtech.jts.geom.Coordinate;
import org.locationtech.jts.geom.GeometryFactory;
import org.locationtech.jts.geom.Point;
import org.locationtech.jts.geom.PrecisionModel;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ReportServiceImpl implements ReportService {

    private final ReportRepository repository;
    private final UserRepository userRepository;

    @Override
    @Transactional
    public ReportResponse create(ReportRequest request) {
        ReportCategory category = Enum.valueOf(ReportCategory.class, request.getCategory());

        Point point = null;
        if (request.getLatitude() != null && request.getLongitude() != null) {
            GeometryFactory gf = new GeometryFactory(new PrecisionModel(), 4326);
            point = gf.createPoint(new Coordinate(request.getLongitude(), request.getLatitude()));
            Optional<Report> existing = repository.findActiveReportByCategoryNear(point, 50.0, category.name());
            if (existing.isPresent()) {
                Report report = existing.get();
                // TODO: device/ip identity is not available, same-user + same-category + 10-minute merge is applied here.
                boolean sameUser = report.getUser() != null && report.getUser().getId().equals(request.getUserId());
                Instant firstSeen = report.getCreatedAt() == null ? Instant.EPOCH : report.getCreatedAt();
                boolean within10Minutes = Duration.between(firstSeen, Instant.now()).toMinutes() <= 10;
                if (sameUser && within10Minutes) {
                    report.setUpdatedAt(Instant.now());
                    report = repository.save(report);
                    return toResponse(report);
                }
            }
        }

        Report report = new Report();
        User user = userRepository.findById(request.getUserId())
                .orElseThrow(() -> new IllegalArgumentException("Kullanici bulunamadi"));
        report.setUser(user);
        report.setCategory(category);
        report.setDescription(request.getDescription());
        if (point != null) {
            report.setLocation(point);
        }
        report = repository.save(report);
        return toResponse(report);
    }

    @Override
    @Transactional(readOnly = true)
    public List<ReportResponse> listAll() {
        return repository.findActiveReportsWithin12Hours().stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public List<ReportResponse> listMine(Long userId) {
        if (userId == null) {
            throw new IllegalArgumentException("userId zorunlu");
        }
        return repository.findAllByUser_IdOrderByCreatedAtDesc(userId).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public ReportResponse updateStatus(Long reportId, String status, Long requestedByUserId, boolean admin) {
        if (status == null || status.isBlank()) {
            throw new IllegalArgumentException("status zorunlu");
        }

        Report report = repository.findById(reportId)
                .orElseThrow(() -> new IllegalArgumentException("Rapor bulunamadi"));

        Long ownerUserId = report.getUser().getId();
        boolean owner = requestedByUserId != null && requestedByUserId.equals(ownerUserId);
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
                .userId(r.getUser().getId())
                .category(r.getCategory() != null ? r.getCategory().name() : null)
                .description(r.getDescription())
                .latitude(r.getLatitude())
                .longitude(r.getLongitude())
                .createdAt(r.getCreatedAt())
                .status(r.getStatus() != null ? r.getStatus().name() : null)
                .confidenceScore(r.getConfidenceScore())
                .riskCenterLatitude(r.getLatitude())
                .riskCenterLongitude(r.getLongitude())
                .build();
    }
}


