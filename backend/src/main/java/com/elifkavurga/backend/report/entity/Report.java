package com.elifkavurga.backend.report.entity;

import com.elifkavurga.backend.common.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.locationtech.jts.geom.Point;

@Getter
@Setter
@Entity
@Table(name = "reports")
public class Report extends BaseEntity {
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

    @Column(columnDefinition = "geometry(Point,4326)")
    private Point location;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ReportStatus status = ReportStatus.PENDING;

    // score assigned after verification
    private Double confidenceScore;

    @Transient
    public Double getLatitude() {
        return this.location != null ? this.location.getY() : null;
    }

    @Transient
    public Double getLongitude() {
        return this.location != null ? this.location.getX() : null;
    }

    @Transient
    public void setLatitude(Double lat) {
        if (lat == null) return;
        double lon = this.location != null ? this.location.getX() : 0.0;
        org.locationtech.jts.geom.GeometryFactory gf = new org.locationtech.jts.geom.GeometryFactory(
                new org.locationtech.jts.geom.PrecisionModel(), 4326);
        this.location = gf.createPoint(new org.locationtech.jts.geom.Coordinate(lon, lat));
    }

    @Transient
    public void setLongitude(Double lon) {
        if (lon == null) return;
        double lat = this.location != null ? this.location.getY() : 0.0;
        org.locationtech.jts.geom.GeometryFactory gf = new org.locationtech.jts.geom.GeometryFactory(
                new org.locationtech.jts.geom.PrecisionModel(), 4326);
        this.location = gf.createPoint(new org.locationtech.jts.geom.Coordinate(lon, lat));
    }

    @PrePersist
    public void prePersist() {
        if (this.status == null) {
            this.status = ReportStatus.PENDING;
        }
    }
}
