package com.elifkavurga.backend.auth.service;

import com.elifkavurga.backend.user.entity.User;

public interface TokenService {
    String issueToken(User user);
}
