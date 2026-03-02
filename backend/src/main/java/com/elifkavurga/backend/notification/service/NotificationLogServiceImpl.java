package com.elifkavurga.backend.notification.service;

import com.elifkavurga.backend.notification.dto.NotificationLogResponse;
import com.elifkavurga.backend.notification.entity.NotificationLog;
import com.elifkavurga.backend.notification.entity.NotificationStatus;
import com.elifkavurga.backend.notification.entity.NotificationType;
import com.elifkavurga.backend.notification.repository.NotificationLogRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class NotificationLogServiceImpl implements NotificationLogService {

    private final NotificationLogRepository repository;

    @Override
    public void logSent(Long eventId, NotificationType type, String recipient) {
        NotificationLog log = new NotificationLog();
        log.setEventId(eventId);
        log.setType(type);
        log.setTo(recipient);
        log.setStatus(NotificationStatus.SENT);
        repository.save(log);
    }

    @Override
    public List<NotificationLogResponse> listByEventId(Long eventId) {
        return repository.findAllByEventIdOrderByCreatedAtAsc(eventId).stream()
                .map(log -> NotificationLogResponse.builder()
                        .id(log.getId())
                        .eventId(log.getEventId())
                        .type(log.getType().name())
                        .to(log.getTo())
                        .status(log.getStatus().name())
                        .createdAt(log.getCreatedAt())
                        .build())
                .toList();
    }
}
