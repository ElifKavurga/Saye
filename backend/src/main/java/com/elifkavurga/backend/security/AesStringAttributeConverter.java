package com.elifkavurga.backend.security;

import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;

@Converter
public class AesStringAttributeConverter implements AttributeConverter<String, String> {
    @Override
    public String convertToDatabaseColumn(String attribute) {
        return AesCryptoUtil.encrypt(attribute);
    }

    @Override
    public String convertToEntityAttribute(String dbData) {
        if (dbData == null || dbData.isBlank()) {
            return dbData;
        }

        try {
            String decrypted = AesCryptoUtil.decrypt(dbData);
            if (decrypted == null) {
                return dbData;
            }
            return decrypted;
        } catch (RuntimeException ex) {
            // Backward compatibility: if an existing plain-text value exists in DB.
            return dbData;
        }
    }
}
