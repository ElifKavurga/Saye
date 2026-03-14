package com.elifkavurga.backend.usersettings.entity;

import com.elifkavurga.backend.common.entity.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "user_settings")
public class UserSettings extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false, unique = true)
    private Long userId;

    @Column(name = "profile_visible", nullable = false)
    private Boolean profileVisible = true;

    @Column(name = "location_tracking_enabled", nullable = false)
    private Boolean locationTrackingEnabled = true;

    @Column(name = "background_refresh_enabled", nullable = false)
    private Boolean backgroundRefreshEnabled = true;
}
