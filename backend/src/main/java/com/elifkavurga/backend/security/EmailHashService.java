package com.elifkavurga.backend.security;

import com.elifkavurga.backend.config.AppEncryptionProperties;
import jakarta.annotation.PostConstruct;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.GeneralSecurityException;
import java.util.HexFormat;
import java.util.Locale;

@Service
public class EmailHashService {

    private static final String ALGORITHM = "HmacSHA256";

    private final AppEncryptionProperties properties;
    private SecretKeySpec hmacKey;

    public EmailHashService(AppEncryptionProperties properties) {
        this.properties = properties;
    }

    @PostConstruct
    void init() {
        String rawSecret = properties.getEmailLookupHmacSecret();
        if (!StringUtils.hasText(rawSecret)) {
            throw new IllegalStateException("app.encryption.email-lookup-hmac-secret must be configured");
        }
        this.hmacKey = new SecretKeySpec(
                rawSecret.getBytes(StandardCharsets.UTF_8),
                ALGORITHM
        );
    }

    public String hashEmail(String email) {
        if (!StringUtils.hasText(email)) {
            return null;
        }

        String normalized = email.trim().toLowerCase(Locale.ROOT);

        try {
            Mac mac = Mac.getInstance(ALGORITHM);
            mac.init(hmacKey);
            byte[] digest = mac.doFinal(normalized.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(digest);
        } catch (GeneralSecurityException ex) {
            throw new IllegalStateException("Unable to hash email for lookup", ex);
        }
    }
}
