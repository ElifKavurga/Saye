package com.elifkavurga.backend.emergency.service;

import com.elifkavurga.backend.common.exceptions.BadRequestException;
import com.elifkavurga.backend.emergency.dto.EmergencyStartRequest;
import com.elifkavurga.backend.emergency.dto.EmergencyStatusResponse;
import com.elifkavurga.backend.emergency.entity.EmergencyEvent;
import com.elifkavurga.backend.emergency.entity.EmergencyStatus;
import com.elifkavurga.backend.emergency.repository.EmergencyEventRepository;
import com.elifkavurga.backend.emergencycontact.entity.EmergencyContact;
import com.elifkavurga.backend.emergencycontact.repository.EmergencyContactRepository;
import com.elifkavurga.backend.notification.entity.NotificationType;
import com.elifkavurga.backend.notification.service.NotificationLogService;
import com.elifkavurga.backend.notification.service.NotificationProviderService;
import com.elifkavurga.backend.user.entity.User;
import com.elifkavurga.backend.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.locationtech.jts.geom.Coordinate;
import org.locationtech.jts.geom.GeometryFactory;
import org.locationtech.jts.geom.PrecisionModel;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.Clock;
import java.time.Instant;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

@Service
@RequiredArgsConstructor
public class EmergencyServiceImpl implements EmergencyService {

    private static final String HIGH_RISK = "HIGH";
    private static final String MEDIUM_RISK = "MEDIUM";
    private static final String AUTONOMOUS_EMERGENCY_CALL_NAME = "112 Acil Cagri Merkezi";
    private static final String AUTONOMOUS_EMERGENCY_CALL_NUMBER = "112";

    private final EmergencyEventRepository repository;
    private final EmergencyContactRepository emergencyContactRepository;
    private final NotificationLogService notificationLogService;
    private final NotificationProviderService notificationProviderService;
    private final UserRepository userRepository;
    private final Clock clock;

    @Override
    @Transactional
    public EmergencyStatusResponse start(EmergencyStartRequest request) {
        repository.findFirstByUser_IdAndStatusOrderByStartedAtDesc(request.getUserId(), EmergencyStatus.ACTIVE)
                .ifPresent(event -> {
                    throw new BadRequestException("Kullanicinin zaten aktif bir acil durumu var");
                });

        User user = userRepository.findById(request.getUserId())
                .orElseThrow(() -> new BadRequestException("Kullanici bulunamadi"));

        String normalizedRiskLevel = normalizeRiskLevel(request.getCurrentRiskLevel());
        boolean deviceSmsHandled = Boolean.TRUE.equals(request.getDeviceSmsHandled());

        EmergencyEvent event = new EmergencyEvent();
        event.setUser(user);
        event.setStartedAt(Instant.now(clock));
        event.setStatus(EmergencyStatus.ACTIVE);
        event.setCurrentRiskLevel(normalizedRiskLevel);
        event.setCalledContactName(request.getCalledContactName());
        event.setCalledPhoneNumber(normalizePhoneNumber(request.getCalledPhoneNumber()));
        event.setSharedTo(normalizeRecipients(request.getSharedTo()));

        configureAutonomousDispatch(event, user.getId(), normalizedRiskLevel);

        GeometryFactory gf = new GeometryFactory(new PrecisionModel(), 4326);
        event.setLocation(gf.createPoint(new Coordinate(request.getLongitude(), request.getLatitude())));

        EmergencyEvent savedEvent = repository.save(event);
        dispatchNotifications(savedEvent, normalizedRiskLevel, deviceSmsHandled);
        return toResponse(savedEvent);
    }

    @Override
    @Transactional
    public EmergencyStatusResponse stop(Long userId) {
        EmergencyEvent event = repository.findFirstByUser_IdAndStatusOrderByStartedAtDesc(userId, EmergencyStatus.ACTIVE)
                .orElseThrow(() -> new BadRequestException("Aktif acil durum bulunamadi"));

        event.setStatus(EmergencyStatus.RESOLVED);
        event.setEndedAt(Instant.now(clock));
        return toResponse(repository.save(event));
    }

    @Override
    @Transactional(readOnly = true)
    public EmergencyStatusResponse status(Long userId) {
        return repository.findFirstByUser_IdAndStatusOrderByStartedAtDesc(userId, EmergencyStatus.ACTIVE)
                .map(this::toResponse)
                .orElseGet(() -> EmergencyStatusResponse.builder()
                        .userId(userId)
                        .active(false)
                        .sharedTo(List.of())
                        .build());
    }

    private void configureAutonomousDispatch(EmergencyEvent event, Long userId, String normalizedRiskLevel) {
        if (HIGH_RISK.equals(normalizedRiskLevel)) {
            event.setCalledContactName(AUTONOMOUS_EMERGENCY_CALL_NAME);
            event.setCalledPhoneNumber(AUTONOMOUS_EMERGENCY_CALL_NUMBER);
            event.setSharedTo(List.of());
            return;
        }

        if (MEDIUM_RISK.equals(normalizedRiskLevel)) {
            event.setCalledContactName(null);
            event.setCalledPhoneNumber(null);
            event.setSharedTo(loadNormalizedEmergencyRecipients(userId));
        }
    }

    private List<String> loadNormalizedEmergencyRecipients(Long userId) {
        return emergencyContactRepository.findAllByUser_IdOrderByIsPrimaryDescCreatedAtAsc(userId).stream()
                .map(EmergencyContact::getPhoneNumber)
                .filter(StringUtils::hasText)
                .map(String::trim)
                .distinct()
                .toList();
    }

    private void dispatchNotifications(EmergencyEvent event, String normalizedRiskLevel, boolean deviceSmsHandled) {
        String smsMessage = buildSmsMessage(event);
        String voiceMessage = buildVoiceMessage(event);

        if (HIGH_RISK.equals(normalizedRiskLevel)) {
            dispatchCall(event.getId(), event.getCalledPhoneNumber(), voiceMessage);
            return;
        }

        if (MEDIUM_RISK.equals(normalizedRiskLevel)) {
            if (!deviceSmsHandled) {
                for (String recipient : event.getSharedTo()) {
                    dispatchSms(event.getId(), recipient, smsMessage);
                }
            }
            return;
        }

        if (StringUtils.hasText(event.getCalledPhoneNumber())) {
            dispatchCall(event.getId(), event.getCalledPhoneNumber(), voiceMessage);
        }
        if (!deviceSmsHandled) {
            for (String recipient : event.getSharedTo()) {
                dispatchSms(event.getId(), recipient, smsMessage);
            }
        }
    }

    private void dispatchCall(Long eventId, String phoneNumber, String voiceMessage) {
        if (!StringUtils.hasText(phoneNumber)) {
            return;
        }
        notificationProviderService.makeCall(phoneNumber, voiceMessage);
        notificationLogService.logSent(eventId, NotificationType.CALL, phoneNumber);
    }

    private void dispatchSms(Long eventId, String phoneNumber, String message) {
        if (!StringUtils.hasText(phoneNumber)) {
            return;
        }
        notificationProviderService.sendSms(phoneNumber, message);
        notificationLogService.logSent(eventId, NotificationType.SMS, phoneNumber);
    }

    private String buildSmsMessage(EmergencyEvent event) {
        return "Kullanici acil durum baslatti, konumu: "
                + event.getLatitude()
                + ", "
                + event.getLongitude();
    }

    private String buildVoiceMessage(EmergencyEvent event) {
        return "Yuksek riskli acil durum kaydi. Konum: "
                + event.getLatitude()
                + ", "
                + event.getLongitude();
    }

    private String normalizeRiskLevel(String currentRiskLevel) {
        return StringUtils.hasText(currentRiskLevel) ? currentRiskLevel.trim().toUpperCase() : null;
    }

    private String normalizePhoneNumber(String phoneNumber) {
        return StringUtils.hasText(phoneNumber) ? phoneNumber.trim() : null;
    }

    private List<String> normalizeRecipients(List<String> recipients) {
        if (recipients == null || recipients.isEmpty()) {
            return List.of();
        }

        Set<String> normalizedRecipients = new LinkedHashSet<>();
        for (String recipient : recipients) {
            if (StringUtils.hasText(recipient)) {
                normalizedRecipients.add(recipient.trim());
            }
        }
        return List.copyOf(normalizedRecipients);
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
