package com.elifkavurga.backend.report.repository;

import com.elifkavurga.backend.report.entity.Report;
import com.elifkavurga.backend.report.repository.projection.NearbyReportProjection;
import org.locationtech.jts.geom.Point;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.Optional;

@Repository
public interface ReportRepository extends JpaRepository<Report, Long> {
    java.util.List<Report> findAllByUser_IdOrderByCreatedAtDesc(Long userId);

    @Query(value = """
            SELECT
                r.id AS id,
                r.user_id AS userId,
                r.category AS category,
                r.description AS description,
                ST_Y(r.location) AS latitude,
                ST_X(r.location) AS longitude,
                r.created_at AS createdAt,
                r.status AS status,
                r.confidence_score AS confidenceScore,
                ST_Distance(
                    r.location::geography,
                    CAST(:center AS geography)
                ) AS distanceMeters
            FROM reports r
            WHERE r.location IS NOT NULL
              AND r.status IN ('PENDING', 'REVIEWING')
              AND (r.created_at >= :cutoff OR r.updated_at >= :cutoff)
              AND ST_DWithin(
                  r.location::geography,
                  CAST(:center AS geography),
                  :radiusMeters
              )
            ORDER BY distanceMeters ASC
            """, nativeQuery = true)
    java.util.List<NearbyReportProjection> findActiveNearbyReports(@Param("center") Point center,
                                                                   @Param("radiusMeters") double radiusMeters,
                                                                   @Param("cutoff") Instant cutoff);

    @Query(value = """
            SELECT *
            FROM reports r
            WHERE r.category = :category
              AND r.status IN ('PENDING', 'REVIEWING')
              AND (r.created_at >= (NOW() - INTERVAL '12 hours')
                   OR r.updated_at >= (NOW() - INTERVAL '12 hours'))
              AND ST_DWithin(
                  r.location::geography,
                  CAST(:center AS geography),
                  :radiusMeters
              )
            ORDER BY GREATEST(r.updated_at, r.created_at) DESC
            LIMIT 1
            """, nativeQuery = true)
    Optional<Report> findActiveReportByCategoryNear(@Param("center") Point center,
                                                    @Param("radiusMeters") double radiusMeters,
                                                    @Param("category") String category);

    @Query(value = """
            SELECT *
            FROM reports r
            WHERE r.status IN ('PENDING', 'REVIEWING')
              AND (r.created_at >= (NOW() - INTERVAL '12 hours')
               OR r.updated_at >= (NOW() - INTERVAL '12 hours'))
            """, nativeQuery = true)
    java.util.List<Report> findActiveReportsWithin12Hours();
}
