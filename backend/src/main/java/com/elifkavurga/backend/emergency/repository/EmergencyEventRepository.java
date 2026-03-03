package com.elifkavurga.backend.emergency.repository;

import com.elifkavurga.backend.emergency.entity.EmergencyEvent;
import com.elifkavurga.backend.emergency.entity.EmergencyStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface EmergencyEventRepository extends JpaRepository<EmergencyEvent, Long> {
    Optional<EmergencyEvent> findFirstByUser_IdAndStatusOrderByStartedAtDesc(Long userId, EmergencyStatus status);
}
