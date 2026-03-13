package com.elifkavurga.backend.notification.repository;

import com.elifkavurga.backend.notification.entity.NotificationLog;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface NotificationLogRepository extends JpaRepository<NotificationLog, Long> {
    List<NotificationLog> findAllByEvent_IdOrderByCreatedAtAsc(Long eventId);
}
