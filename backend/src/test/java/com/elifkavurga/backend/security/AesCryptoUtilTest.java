package com.elifkavurga.backend.security;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class AesCryptoUtilTest {

    @Test
    void encryptionAndDecryptionShouldBeReversible() {
        String secret = "saye-test-secret-key-32-chars!!";
        String plainText = "Ayşe Demir";

        AesCryptoUtil.initialize(secret);
        String encrypted = AesCryptoUtil.encrypt(plainText);
        String decrypted = AesCryptoUtil.decrypt(encrypted);

        assertThat(encrypted).isNotEqualTo(plainText);
        assertThat(encrypted).contains(":");
        assertThat(decrypted).isEqualTo(plainText);
    }

    @Test
    void encryptingSameValueTwiceShouldProduceDifferentCipherForRandomIV() {
        String secret = "saye-test-secret-key-32-chars!!";
        String plainText = "5551112233";

        AesCryptoUtil.initialize(secret);
        String first = AesCryptoUtil.encrypt(plainText);
        String second = AesCryptoUtil.encrypt(plainText);

        assertThat(first).isNotEqualTo(second);
        assertThat(AesCryptoUtil.decrypt(first)).isEqualTo(plainText);
        assertThat(AesCryptoUtil.decrypt(second)).isEqualTo(plainText);
    }
}

