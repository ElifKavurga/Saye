package com.elifkavurga.backend.emergency.entity;

import jakarta.persistence.CollectionTable;
import jakarta.persistence.Column;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;
import org.locationtech.jts.geom.Point;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
@Entity
@Table(name = "emergency_events")
public class EmergencyEvent {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long userId;

    @Column(nullable = false, updatable = false)
    private Instant startedAt;

    @Column
    private Instant endedAt;

    @Column(columnDefinition = "geometry(Point,4326)")
    private Point startLocation;

    @Column(nullable = false)
    private Boolean isActive = true;

    @ElementCollection
    @CollectionTable(name = "emergency_event_shared_to", joinColumns = @JoinColumn(name = "event_id"))
    @Column(name = "contact_value", nullable = false)
    private List<String> sharedTo = new ArrayList<>();

    @PrePersist
    public void prePersist() {
        if (this.startedAt == null) {
            this.startedAt = Instant.now();
        }
        if (this.isActive == null) {
            this.isActive = true;
        }
    }

    public Double getLatitude() {
        return this.startLocation != null ? this.startLocation.getY() : null;
    }

    public Double getLongitude() {
        return this.startLocation != null ? this.startLocation.getX() : null;
    }
}
