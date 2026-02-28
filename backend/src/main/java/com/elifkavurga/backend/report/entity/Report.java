package com.elifkavurga.backend.report.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.Instant;

@Getter
@Setter
@Entity
@Table(name = "reports")
public class Report {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // user may be anonymous
    @Column(name = "user_id")
    private Long userId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ReportCategory category;

    @Column(columnDefinition = "text")
    private String description;

    // either store as separate lat/lng or PostGIS geometry
    // latitude/longitude for the event location (alternatively could use PostGIS geometry)
    private Double latitude;

    private Double longitude;

    @Column(nullable = false, updatable = false)
    private Instant createdAt;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ReportStatus status = ReportStatus.ACTIVE;

    // score assigned after verification
    private Double confidenceScore;

    @PrePersist
    public void prePersist() {
        Instant now = Instant.now();
        this.createdAt = now;
        if (this.status == null) {
            this.status = ReportStatus.ACTIVE;
        }
    }
}
