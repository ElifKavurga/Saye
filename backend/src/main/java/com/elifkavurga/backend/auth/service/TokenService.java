package com.elifkavurga.backend.auth.service;

import com.elifkavurga.backend.user.entity.User;

public interface TokenService {
    String issueAccessToken(User user);

    String issueRefreshToken(User user);

    Long validateAccessToken(String token);

    Long validateRefreshToken(String token);
}
