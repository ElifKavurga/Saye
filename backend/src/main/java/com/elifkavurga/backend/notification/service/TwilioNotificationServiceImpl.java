package com.elifkavurga.backend.notification.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.util.StringUtils;
import org.springframework.web.client.RestTemplate;

@Service
public class TwilioNotificationServiceImpl implements NotificationProviderService {

    private static final Logger log = LoggerFactory.getLogger(TwilioNotificationServiceImpl.class);
    private static final String TWILIO_SMS_URL_TEMPLATE =
            "https://api.twilio.com/2010-04-01/Accounts/%s/Messages.json";

    private final RestTemplate restTemplate;

    @Value("${twilio.account-sid}")
    private String accountSid;

    @Value("${twilio.auth-token}")
    private String authToken;

    @Value("${twilio.phone-number}")
    private String phoneNumber;

    public TwilioNotificationServiceImpl(RestTemplateBuilder restTemplateBuilder) {
        this.restTemplate = restTemplateBuilder.build();
    }

    @Override
    public void sendSms(String phoneNumber, String message) {
        if (!StringUtils.hasText(accountSid)
                || !StringUtils.hasText(authToken)
                || !StringUtils.hasText(this.phoneNumber)) {
            log.warn(
                    "Twilio SMS skipped because configuration is incomplete. to={}, client={}",
                    phoneNumber,
                    restTemplate.getClass().getSimpleName()
            );
            return;
        }

        HttpHeaders headers = new HttpHeaders();
        headers.setBasicAuth(accountSid, authToken);
        headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);

        MultiValueMap<String, String> formData = new LinkedMultiValueMap<>();
        formData.add("To", phoneNumber);
        formData.add("From", this.phoneNumber);
        formData.add("Body", message);

        HttpEntity<MultiValueMap<String, String>> requestEntity = new HttpEntity<>(formData, headers);
        String url = TWILIO_SMS_URL_TEMPLATE.formatted(accountSid);

        ResponseEntity<String> response = restTemplate.postForEntity(url, requestEntity, String.class);
        log.info(
                "Twilio SMS request completed. to={}, statusCode={}, client={}",
                phoneNumber,
                response.getStatusCode(),
                restTemplate.getClass().getSimpleName()
        );
    }

    @Override
    public void makeCall(String phoneNumber, String voiceMessage) {
        log.info(
                "Mock call dispatch prepared via Twilio client scaffold. phoneNumber={}, voiceMessage={}, client={}",
                phoneNumber,
                voiceMessage,
                restTemplate.getClass().getSimpleName()
        );
    }
}
