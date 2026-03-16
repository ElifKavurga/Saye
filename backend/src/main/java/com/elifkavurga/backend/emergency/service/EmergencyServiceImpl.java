package com.elifkavurga.backend.emergency.service;

import com.elifkavurga.backend.common.exceptions.BadRequestException;
import com.elifkavurga.backend.emergency.dto.EmergencyStartRequest;
import com.elifkavurga.backend.emergency.dto.EmergencyStatusResponse;
import com.elifkavurga.backend.emergency.entity.EmergencyEvent;
import com.elifkavurga.backend.emergency.entity.EmergencyStatus;
import com.elifkavurga.backend.emergency.repository.EmergencyEventRepository;
import com.elifkavurga.backend.notification.entity.NotificationType;
import com.elifkavurga.backend.notification.service.NotificationLogService;
import com.elifkavurga.backend.user.entity.User;
import com.elifkavurga.backend.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.locationtech.jts.geom.Coordinate;
import org.locationtech.jts.geom.GeometryFactory;
import org.locationtech.jts.geom.PrecisionModel;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.Clock;
import java.time.Instant;
import java.util.List;

@Service
@RequiredArgsConstructor
public class EmergencyServiceImpl implements EmergencyService {

    private final EmergencyEventRepository repository;
    private final NotificationLogService notificationLogService;
    private final UserRepository userRepository;
    private final Clock clock;

    @Override
    public EmergencyStatusResponse start(EmergencyStartRequest request) {
        repository.findFirstByUser_IdAndStatusOrderByStartedAtDesc(request.getUserId(), EmergencyStatus.ACTIVE)
                .ifPresent(event -> {
                    throw new BadRequestException("Kullanicinin zaten aktif bir acil durumu var");
                });

        User user = userRepository.findById(request.getUserId())
                .orElseThrow(() -> new BadRequestException("Kullanici bulunamadi"));

        EmergencyEvent event = new EmergencyEvent();
        event.setUser(user);
        event.setStartedAt(Instant.now(clock));
        event.setStatus(EmergencyStatus.ACTIVE);
        event.setCurrentRiskLevel(request.getCurrentRiskLevel());
        event.setCalledContactName(request.getCalledContactName());
        event.setCalledPhoneNumber(request.getCalledPhoneNumber());
        event.setSharedTo(request.getSharedTo() != null ? List.copyOf(request.getSharedTo()) : List.of());

        GeometryFactory gf = new GeometryFactory(new PrecisionModel(), 4326);
        event.setLocation(gf.createPoint(new Coordinate(request.getLongitude(), request.getLatitude())));

        EmergencyEvent savedEvent = repository.save(event);
        if (StringUtils.hasText(savedEvent.getCalledPhoneNumber())) {
            notificationLogService.logSent(savedEvent.getId(), NotificationType.CALL, savedEvent.getCalledPhoneNumber());
        }
        for (String recipient : savedEvent.getSharedTo()) {
            notificationLogService.logSent(savedEvent.getId(), NotificationType.SMS, recipient);
        }

        return toResponse(savedEvent);
    }

    @Override
    public EmergencyStatusResponse stop(Long userId) {
        EmergencyEvent event = repository.findFirstByUser_IdAndStatusOrderByStartedAtDesc(userId, EmergencyStatus.ACTIVE)
                .orElseThrow(() -> new BadRequestException("Aktif acil durum bulunamadi"));

        event.setStatus(EmergencyStatus.RESOLVED);
        event.setEndedAt(Instant.now(clock));
        return toResponse(repository.save(event));
    }

    @Override
    public EmergencyStatusResponse status(Long userId) {
        return repository.findFirstByUser_IdAndStatusOrderByStartedAtDesc(userId, EmergencyStatus.ACTIVE)
                .map(this::toResponse)
                .orElseGet(() -> EmergencyStatusResponse.builder()
                        .userId(userId)
                        .active(false)
                        .sharedTo(List.of())
                        .build());
    }

    private EmergencyStatusResponse toResponse(EmergencyEvent event) {
        return EmergencyStatusResponse.builder()
                .id(event.getId())
                .userId(event.getUser() != null ? event.getUser().getId() : null)
                .startedAt(event.getStartedAt())
                .endedAt(event.getEndedAt())
                .latitude(event.getLatitude())
                .longitude(event.getLongitude())
                .currentRiskLevel(event.getCurrentRiskLevel())
                .calledContactName(event.getCalledContactName())
                .calledPhoneNumber(event.getCalledPhoneNumber())
                .active(event.getStatus() == EmergencyStatus.ACTIVE)
                .sharedTo(event.getSharedTo() != null ? List.copyOf(event.getSharedTo()) : List.of())
                .build();
    }
}
