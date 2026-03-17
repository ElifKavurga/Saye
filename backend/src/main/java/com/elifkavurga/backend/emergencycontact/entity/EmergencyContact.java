package com.elifkavurga.backend.emergencycontact.entity;

import com.elifkavurga.backend.common.entity.BaseEntity;
import com.elifkavurga.backend.user.entity.User;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Persistence;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "emergency_contacts")
public class EmergencyContact extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false)
    private String name;

    @Column(name = "phone_number", nullable = false)
    private String phoneNumber;

    @Column(name = "is_primary", nullable = false)
    private Boolean isPrimary = false;

    public void setUser(User user) {
        if (this.user == user) {
            return;
        }

        User previousUser = this.user;
        this.user = user;

        if (previousUser != null && Persistence.getPersistenceUtil().isLoaded(previousUser, "emergencyContacts")) {
            previousUser.getEmergencyContacts().remove(this);
        }
        if (user != null
                && Persistence.getPersistenceUtil().isLoaded(user, "emergencyContacts")
                && !user.getEmergencyContacts().contains(this)) {
            user.getEmergencyContacts().add(this);
        }
    }
}
