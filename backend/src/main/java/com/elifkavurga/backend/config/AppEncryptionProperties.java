package com.elifkavurga.backend.config;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;

@Getter
@Setter
@ConfigurationProperties(prefix = "app.encryption")
public class AppEncryptionProperties {
    private String aesSecretKey;
    private String emailLookupHmacSecret = "saye-email-lookup-hmac-secret-change-me-2026";
}
