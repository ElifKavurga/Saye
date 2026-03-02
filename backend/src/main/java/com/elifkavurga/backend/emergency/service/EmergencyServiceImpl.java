package com.elifkavurga.backend.emergency.service;

import com.elifkavurga.backend.common.exceptions.BadRequestException;
import com.elifkavurga.backend.emergency.dto.EmergencyStartRequest;
import com.elifkavurga.backend.emergency.dto.EmergencyStatusResponse;
import com.elifkavurga.backend.emergency.entity.EmergencyEvent;
import com.elifkavurga.backend.emergency.repository.EmergencyEventRepository;
import com.elifkavurga.backend.notification.entity.NotificationType;
import com.elifkavurga.backend.notification.service.NotificationLogService;
import lombok.RequiredArgsConstructor;
import org.locationtech.jts.geom.Coordinate;
import org.locationtech.jts.geom.GeometryFactory;
import org.locationtech.jts.geom.PrecisionModel;
import org.springframework.stereotype.Service;

import java.time.Clock;
import java.time.Instant;
import java.util.List;

@Service
@RequiredArgsConstructor
public class EmergencyServiceImpl implements EmergencyService {

    private final EmergencyEventRepository repository;
    private final NotificationLogService notificationLogService;
    private final Clock clock;

    @Override
    public EmergencyStatusResponse start(EmergencyStartRequest request) {
        repository.findFirstByUserIdAndIsActiveTrueOrderByStartedAtDesc(request.getUserId())
                .ifPresent(event -> {
                    throw new BadRequestException("Kullanicinin zaten aktif bir acil durumu var");
                });

        EmergencyEvent event = new EmergencyEvent();
        event.setUserId(request.getUserId());
        event.setStartedAt(Instant.now(clock));
        event.setIsActive(true);
        event.setSharedTo(request.getSharedTo() != null ? List.copyOf(request.getSharedTo()) : List.of());

        GeometryFactory gf = new GeometryFactory(new PrecisionModel(), 4326);
        event.setStartLocation(gf.createPoint(new Coordinate(request.getLongitude(), request.getLatitude())));

        EmergencyEvent savedEvent = repository.save(event);
        for (String recipient : savedEvent.getSharedTo()) {
            notificationLogService.logSent(savedEvent.getId(), NotificationType.SMS, recipient);
        }

        return toResponse(savedEvent);
    }

    @Override
    public EmergencyStatusResponse stop(Long userId) {
        EmergencyEvent event = repository.findFirstByUserIdAndIsActiveTrueOrderByStartedAtDesc(userId)
                .orElseThrow(() -> new BadRequestException("Aktif acil durum bulunamadi"));

        event.setIsActive(false);
        event.setEndedAt(Instant.now(clock));
        return toResponse(repository.save(event));
    }

    @Override
    public EmergencyStatusResponse status(Long userId) {
        return repository.findFirstByUserIdAndIsActiveTrueOrderByStartedAtDesc(userId)
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
                .userId(event.getUserId())
                .startedAt(event.getStartedAt())
                .endedAt(event.getEndedAt())
                .latitude(event.getLatitude())
                .longitude(event.getLongitude())
                .active(Boolean.TRUE.equals(event.getIsActive()))
                .sharedTo(event.getSharedTo() != null ? List.copyOf(event.getSharedTo()) : List.of())
                .build();
    }
}
