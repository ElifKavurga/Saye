package com.elifkavurga.backend.auth.service;

import com.elifkavurga.backend.common.exceptions.UnauthorizedException;
import com.elifkavurga.backend.config.AppSecurityProperties;
import com.elifkavurga.backend.user.entity.User;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.time.Clock;
import java.time.Instant;
import java.util.Date;

@Service
@RequiredArgsConstructor
public class JwtTokenService implements TokenService {

    private static final String TOKEN_TYPE_CLAIM = "type";
    private static final String ACCESS_TOKEN_TYPE = "access";
    private static final String REFRESH_TOKEN_TYPE = "refresh";

    private final AppSecurityProperties appSecurityProperties;
    private final Clock clock;

    @Override
    public String issueAccessToken(User user) {
        return issueToken(user, ACCESS_TOKEN_TYPE, appSecurityProperties.getAccessTokenTtl().toMillis());
    }

    @Override
    public String issueRefreshToken(User user) {
        return issueToken(user, REFRESH_TOKEN_TYPE, appSecurityProperties.getRefreshTokenTtl().toMillis());
    }

    @Override
    public Long validateAccessToken(String token) {
        return validateToken(token, ACCESS_TOKEN_TYPE, "Access token");
    }

    @Override
    public Long validateRefreshToken(String token) {
        return validateToken(token, REFRESH_TOKEN_TYPE, "Refresh token");
    }

    private String issueToken(User user, String tokenType, long ttlMillis) {
        Instant now = Instant.now(clock);
        return Jwts.builder()
                .subject(String.valueOf(user.getId()))
                .claim(TOKEN_TYPE_CLAIM, tokenType)
                .issuedAt(Date.from(now))
                .expiration(Date.from(now.plusMillis(ttlMillis)))
                .signWith(signingKey())
                .compact();
    }

    private Long validateToken(String token, String expectedType, String tokenLabel) {
        Claims claims;
        try {
            claims = Jwts.parser()
                    .verifyWith(signingKey())
                    .build()
                    .parseSignedClaims(token)
                    .getPayload();
        } catch (JwtException | IllegalArgumentException ex) {
            throw new UnauthorizedException(tokenLabel + " is invalid or expired");
        }

        String actualType = claims.get(TOKEN_TYPE_CLAIM, String.class);
        if (!expectedType.equals(actualType)) {
            throw new UnauthorizedException(tokenLabel + " type is invalid");
        }

        try {
            return Long.parseLong(claims.getSubject());
        } catch (NumberFormatException ex) {
            throw new UnauthorizedException(tokenLabel + " subject is invalid");
        }
    }

    private SecretKey signingKey() {
        byte[] secret = appSecurityProperties.getJwtSecret().getBytes(StandardCharsets.UTF_8);
        if (secret.length < 32) {
            throw new IllegalStateException("JWT secret must be at least 32 bytes long");
        }
        return Keys.hmacShaKeyFor(secret);
    }
}
