package com.elifkavurga.backend.auth.service;

import com.elifkavurga.backend.user.entity.User;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
public class DummyTokenService implements TokenService {
    @Override
    public String issueToken(User user) {
        return UUID.randomUUID().toString();
    }
}
