package com.elifkavurga.backend.notification.service;

public interface NotificationProviderService {
    void sendSms(String phoneNumber, String message);

    void makeCall(String phoneNumber, String voiceMessage);
}
