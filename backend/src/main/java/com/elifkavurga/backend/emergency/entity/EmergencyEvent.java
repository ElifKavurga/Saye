package com.elifkavurga.backend.emergency.entity;

import com.elifkavurga.backend.common.entity.BaseEntity;
import com.elifkavurga.backend.user.entity.User;
import com.elifkavurga.backend.security.AesStringAttributeConverter;
import jakarta.persistence.CollectionTable;
import jakarta.persistence.Column;
import jakarta.persistence.ElementCollection;
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
public class EmergencyEvent extends BaseEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false, updatable = false)
    private Instant startedAt;

    @Column
    private Instant endedAt;

    @Column(columnDefinition = "geometry(Point,4326)")
    private Point location;

    @Column(name = "current_risk_level")
    private String currentRiskLevel;

    @Convert(converter = AesStringAttributeConverter.class)
    @Column(name = "called_contact_name")
    private String calledContactName;

    @Convert(converter = AesStringAttributeConverter.class)
    @Column(name = "called_phone_number")
    private String calledPhoneNumber;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private EmergencyStatus status = EmergencyStatus.ACTIVE;

    @ElementCollection
    @CollectionTable(name = "emergency_event_shared_to", joinColumns = @JoinColumn(name = "event_id"))
    @Convert(converter = AesStringAttributeConverter.class)
    @Column(name = "contact_value", nullable = false)
    private List<String> sharedTo = new ArrayList<>();

    @PrePersist
    public void prePersist() {
        if (this.startedAt == null) {
            this.startedAt = Instant.now();
        }
        if (this.status == null) {
            this.status = EmergencyStatus.ACTIVE;
        }
    }

    public Double getLatitude() {
        return this.location != null ? this.location.getY() : null;
    }

    public Double getLongitude() {
        return this.location != null ? this.location.getX() : null;
    }
}
