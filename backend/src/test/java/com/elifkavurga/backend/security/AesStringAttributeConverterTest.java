package com.elifkavurga.backend.security;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class AesStringAttributeConverterTest {

    @Test
    void converterShouldEncryptAndDecryptFieldValue() {
        AesCryptoUtil.initialize("saye-test-secret-key-32-chars!!");
        AesStringAttributeConverter converter = new AesStringAttributeConverter();

        String name = "Emir Güneş";
        String dbValue = converter.convertToDatabaseColumn(name);
        String domainValue = converter.convertToEntityAttribute(dbValue);

        assertThat(dbValue).isNotNull();
        assertThat(dbValue).isNotEqualTo(name);
        assertThat(domainValue).isEqualTo(name);
    }

    @Test
    void converterShouldAllowLegacyPlainTextValue() {
        AesCryptoUtil.initialize("saye-test-secret-key-32-chars!!");
        AesStringAttributeConverter converter = new AesStringAttributeConverter();

        String plainTextInDb = "5553331122";
        String domainValue = converter.convertToEntityAttribute(plainTextInDb);

        assertThat(domainValue).isEqualTo(plainTextInDb);
    }
}

