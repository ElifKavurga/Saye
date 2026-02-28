package com.elifkavurga.backend.report.repository;

import com.elifkavurga.backend.report.entity.Report;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ReportRepository extends JpaRepository<Report, Long> {
    // additional query methods can be added later
}
