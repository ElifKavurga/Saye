package com.elifkavurga.backend.report.repository;

import com.elifkavurga.backend.report.entity.Report;
import org.locationtech.jts.geom.Point;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

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
}
