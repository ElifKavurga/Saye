package com.elifkavurga.backend.notification.service;

import com.elifkavurga.backend.common.exceptions.BadRequestException;
import com.elifkavurga.backend.emergency.entity.EmergencyEvent;
import com.elifkavurga.backend.emergency.repository.EmergencyEventRepository;
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
    private final EmergencyEventRepository emergencyEventRepository;

    @Override
    public void logSent(Long eventId, NotificationType type, String recipient) {
        EmergencyEvent event = emergencyEventRepository.findById(eventId)
                .orElseThrow(() -> new BadRequestException("Acil durum olayi bulunamadi"));

        NotificationLog log = new NotificationLog();
        log.setEvent(event);
        log.setType(type);
        log.setTo(recipient);
        log.setUser(event.getUser());
        log.setMessage("Acil durum bildirimi gonderildi: " + recipient);
        log.setIsRead(false);
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
