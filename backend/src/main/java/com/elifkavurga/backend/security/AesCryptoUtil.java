package com.elifkavurga.backend.security;

import com.elifkavurga.backend.config.AppEncryptionProperties;
import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.GeneralSecurityException;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;

@Component
public class AesCryptoUtil {
    private static final Logger logger = LoggerFactory.getLogger(AesCryptoUtil.class);
    private static final String ALGORITHM = "AES";
    private static final String TRANSFORMATION = "AES/GCM/NoPadding";
    private static final int GCM_TAG_LENGTH = 128;
    private static final int IV_LENGTH = 12;
    private static volatile SecretKey secretKey;

    private final AppEncryptionProperties properties;

    public AesCryptoUtil(AppEncryptionProperties properties) {
        this.properties = properties;
    }

    @PostConstruct
    void init() {
        initialize(properties.getAesSecretKey());
    }

    public static void initialize(String rawSecret) {
        if (rawSecret == null || rawSecret.isBlank()) {
            throw new IllegalStateException("app.encryption.aes-secret-key must be configured");
        }
        secretKey = new SecretKeySpec(deriveKey(rawSecret), ALGORITHM);
        logger.info("AES encryption initialized for database fields.");
    }

    public static String encrypt(String plainText) {
        if (plainText == null) {
            return null;
        }

        ensureInitialized();

        try {
            byte[] iv = new byte[IV_LENGTH];
            SecureRandom random = new SecureRandom();
            random.nextBytes(iv);

            Cipher cipher = Cipher.getInstance(TRANSFORMATION);
            GCMParameterSpec spec = new GCMParameterSpec(GCM_TAG_LENGTH, iv);
            cipher.init(Cipher.ENCRYPT_MODE, secretKey, spec);

            byte[] cipherText = cipher.doFinal(plainText.getBytes(StandardCharsets.UTF_8));
            String encodedIv = Base64.getEncoder().encodeToString(iv);
            String encodedCipher = Base64.getEncoder().encodeToString(cipherText);
            return encodedIv + ":" + encodedCipher;
        } catch (GeneralSecurityException ex) {
            throw new IllegalStateException("Encryption failed", ex);
        }
    }

    public static String decrypt(String encryptedText) {
        if (encryptedText == null) {
            return null;
        }

        ensureInitialized();

        try {
            String[] parts = encryptedText.split(":");
            if (parts.length != 2) {
                return null;
            }

            byte[] iv = Base64.getDecoder().decode(parts[0]);
            byte[] cipherText = Base64.getDecoder().decode(parts[1]);

            Cipher cipher = Cipher.getInstance(TRANSFORMATION);
            GCMParameterSpec spec = new GCMParameterSpec(GCM_TAG_LENGTH, iv);
            cipher.init(Cipher.DECRYPT_MODE, secretKey, spec);

            byte[] plainText = cipher.doFinal(cipherText);
            return new String(plainText, StandardCharsets.UTF_8);
        } catch (GeneralSecurityException ex) {
            throw new IllegalStateException("Decryption failed", ex);
        }
    }

    static byte[] deriveKey(String rawSecret) {
        try {
            MessageDigest sha = MessageDigest.getInstance("SHA-256");
            return sha.digest(rawSecret.getBytes(StandardCharsets.UTF_8));
        } catch (GeneralSecurityException ex) {
            throw new IllegalStateException("Failed to build AES key", ex);
        }
    }

    private static void ensureInitialized() {
        if (secretKey == null) {
            throw new IllegalStateException(
                    "AES key not initialized. Configure app.encryption.aes-secret-key"
            );
        }
    }
}
