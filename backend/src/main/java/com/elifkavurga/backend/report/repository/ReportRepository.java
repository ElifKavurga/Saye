package com.elifkavurga.backend.report.repository;

import com.elifkavurga.backend.report.entity.Report;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface ReportRepository extends JpaRepository<Report, Long> {
    java.util.List<Report> findAllByUserIdOrderByCreatedAtDesc(Long userId);

    // find reports where location is within radius (meters) of given point
    @Query(value = "SELECT * FROM reports r WHERE ST_DWithin(r.location::geography, ST_SetSRID(ST_MakePoint(:lng, :lat), 4326)::geography, :radius)", nativeQuery = true)
    java.util.List<Report> findNearby(@org.springframework.data.repository.query.Param("lat") double lat,
                                      @org.springframework.data.repository.query.Param("lng") double lng,
                                      @org.springframework.data.repository.query.Param("radius") double radiusMeters);
}
