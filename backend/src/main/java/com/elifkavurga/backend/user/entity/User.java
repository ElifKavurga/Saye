package com.elifkavurga.backend.user.entity;

import com.elifkavurga.backend.common.entity.BaseEntity;
import com.elifkavurga.backend.emergencycontact.entity.EmergencyContact;
import com.elifkavurga.backend.security.AesStringAttributeConverter;
import com.elifkavurga.backend.userhealthprofile.entity.UserHealthProfile;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Enumerated;
import jakarta.persistence.EnumType;
import jakarta.persistence.Index;
import jakarta.persistence.Convert;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Persistence;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
@Entity
@Table(name = "users", indexes = {
        @Index(name = "uq_users_email_hash", columnList = "email_hash", unique = true)
})
public class User extends BaseEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    @Convert(converter = AesStringAttributeConverter.class)
    private String email;

    @Column(nullable = false, unique = true)
    private String username;

    @Column(nullable = false)
    private String password;

    @Column(name = "email_hash", nullable = false, length = 64)
    private String emailHash;

    @Column
    @Convert(converter = AesStringAttributeConverter.class)
    private String phone;

    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;

    @Enumerated(EnumType.STRING)
    @Column(name = "role", nullable = false, length = 20)
    private UserRole role = UserRole.USER;

    @OneToOne(mappedBy = "user", cascade = CascadeType.ALL)
    private UserHealthProfile healthProfile;

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL)
    private List<EmergencyContact> emergencyContacts = new ArrayList<>();

    public void setHealthProfile(UserHealthProfile healthProfile) {
        if (this.healthProfile == healthProfile) {
            return;
        }

        UserHealthProfile previousHealthProfile = this.healthProfile;
        this.healthProfile = healthProfile;

        if (previousHealthProfile != null
                && previousHealthProfile.getUser() == this) {
            previousHealthProfile.setUser(null);
        }
        if (healthProfile != null && healthProfile.getUser() != this) {
            healthProfile.setUser(this);
        }
    }

    public void setEmergencyContacts(List<EmergencyContact> emergencyContacts) {
        if (Persistence.getPersistenceUtil().isLoaded(this, "emergencyContacts")) {
            List<EmergencyContact> existingContacts = new ArrayList<>(this.emergencyContacts);
            for (EmergencyContact existingContact : existingContacts) {
                removeEmergencyContact(existingContact);
            }
        }

        if (emergencyContacts == null) {
            return;
        }
        for (EmergencyContact emergencyContact : emergencyContacts) {
            addEmergencyContact(emergencyContact);
        }
    }

    public void addEmergencyContact(EmergencyContact emergencyContact) {
        if (emergencyContact == null) {
            return;
        }
        if (Persistence.getPersistenceUtil().isLoaded(this, "emergencyContacts")
                && !emergencyContacts.contains(emergencyContact)) {
            emergencyContacts.add(emergencyContact);
        }
        if (emergencyContact.getUser() != this) {
            emergencyContact.setUser(this);
        }
    }

    public void removeEmergencyContact(EmergencyContact emergencyContact) {
        if (emergencyContact == null) {
            return;
        }
        if (Persistence.getPersistenceUtil().isLoaded(this, "emergencyContacts")) {
            emergencyContacts.remove(emergencyContact);
        }
        if (emergencyContact.getUser() == this) {
            emergencyContact.setUser(null);
        }
    }
}
