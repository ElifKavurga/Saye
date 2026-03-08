package com.elifkavurga.backend.report.repository;

import com.elifkavurga.backend.report.entity.Report;
import org.locationtech.jts.geom.Point;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ReportRepository extends JpaRepository<Report, Long> {
    java.util.List<Report> findAllByUserIdOrderByCreatedAtDesc(Long userId);

    @Query(value = """
            SELECT *
            FROM reports r
            WHERE ST_DWithin(
                r.location::geography,
                CAST(:center AS geography),
                :radiusMeters
            )
            """, nativeQuery = true)
    java.util.List<Report> findByLocationWithinRadius(@Param("center") Point center,
                                                      @Param("radiusMeters") double radiusMeters);

    @Query(value = """
            SELECT *
            FROM reports r
            WHERE r.category = :category
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
            WHERE r.created_at >= (NOW() - INTERVAL '12 hours')
               OR r.updated_at >= (NOW() - INTERVAL '12 hours')
            """, nativeQuery = true)
    java.util.List<Report> findActiveReportsWithin12Hours();
}
