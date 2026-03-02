package com.elifkavurga.backend.notification.service;

import com.elifkavurga.backend.notification.dto.NotificationLogResponse;
import com.elifkavurga.backend.notification.entity.NotificationType;

import java.util.List;

public interface NotificationLogService {
    void logSent(Long eventId, NotificationType type, String recipient);
    List<NotificationLogResponse> listByEventId(Long eventId);
}
