package com.elifkavurga.backend.notification.controller;

import com.elifkavurga.backend.common.ApiResponse;
import com.elifkavurga.backend.notification.dto.NotificationLogResponse;
import com.elifkavurga.backend.notification.service.NotificationLogService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/notifications")
@RequiredArgsConstructor
public class NotificationLogController {

    private final NotificationLogService notificationLogService;

    @GetMapping("/logs")
    public ResponseEntity<ApiResponse<List<NotificationLogResponse>>> list(@RequestParam Long eventId) {
        List<NotificationLogResponse> logs = notificationLogService.listByEventId(eventId);
        return ResponseEntity.ok(ApiResponse.<List<NotificationLogResponse>>builder()
                .success(true)
                .message("Notification logs")
                .data(logs)
                .build());
    }
}
