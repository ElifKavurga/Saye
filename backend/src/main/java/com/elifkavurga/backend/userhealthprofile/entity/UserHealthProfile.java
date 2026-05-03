package com.elifkavurga.backend.userhealthprofile.entity;

import com.elifkavurga.backend.common.entity.BaseEntity;
import com.elifkavurga.backend.user.entity.User;
import com.elifkavurga.backend.security.AesStringAttributeConverter;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Convert;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Persistence;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "user_health_profiles")
public class UserHealthProfile extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Convert(converter = AesStringAttributeConverter.class)
    @Column(name = "blood_type", columnDefinition = "text")
    private String bloodType;

    @Convert(converter = AesStringAttributeConverter.class)
    @Column(name = "allergy_notes", columnDefinition = "text")
    private String allergyNotes;

    @Convert(converter = AesStringAttributeConverter.class)
    @Column(name = "emergency_note", columnDefinition = "text")
    private String emergencyNote;

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;

    public void setUser(User user) {
        if (this.user == user) {
            return;
        }

        User previousUser = this.user;
        this.user = user;

        if (previousUser != null
                && Persistence.getPersistenceUtil().isLoaded(previousUser, "healthProfile")
                && previousUser.getHealthProfile() == this) {
            previousUser.setHealthProfile(null);
        }
        if (user != null
                && Persistence.getPersistenceUtil().isLoaded(user, "healthProfile")
                && user.getHealthProfile() != this) {
            user.setHealthProfile(this);
        }
    }
}
