package com.elifkavurga.backend.report.entity;

import com.elifkavurga.backend.common.entity.BaseEntity;
import com.elifkavurga.backend.user.entity.User;
import com.elifkavurga.backend.security.AesStringAttributeConverter;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Convert;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import jakarta.persistence.Transient;
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

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ReportCategory category;

    @Convert(converter = AesStringAttributeConverter.class)
    @Column(columnDefinition = "text")
    private String description;

    @Column(columnDefinition = "geometry(Point,4326)")
    private Point location;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ReportStatus status = ReportStatus.PENDING;

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
        if (lat == null) {
            return;
        }
        double lon = this.location != null ? this.location.getX() : 0.0;
        org.locationtech.jts.geom.GeometryFactory gf = new org.locationtech.jts.geom.GeometryFactory(
                new org.locationtech.jts.geom.PrecisionModel(), 4326);
        this.location = gf.createPoint(new org.locationtech.jts.geom.Coordinate(lon, lat));
    }

    @Transient
    public void setLongitude(Double lon) {
        if (lon == null) {
            return;
        }
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
