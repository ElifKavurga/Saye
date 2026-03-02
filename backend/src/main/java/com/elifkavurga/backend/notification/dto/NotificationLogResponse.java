package com.elifkavurga.backend.notification.dto;

import lombok.Builder;
import lombok.Getter;

import java.time.Instant;

@Getter
@Builder
public class NotificationLogResponse {
    private Long id;
    private Long eventId;
    private String type;
    private String to;
    private String status;
    private Instant createdAt;
}
