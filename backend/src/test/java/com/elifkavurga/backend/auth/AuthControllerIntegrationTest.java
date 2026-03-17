package com.elifkavurga.backend.auth;

import com.elifkavurga.backend.auth.service.TokenService;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.security.web.FilterChainProxy;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.WebApplicationContext;

import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
class AuthControllerIntegrationTest {

    private MockMvc mvc;

    @Autowired
    private WebApplicationContext context;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private TokenService tokenService;

    @Autowired
    private FilterChainProxy springSecurityFilterChain;

    @BeforeEach
    void setup() {
        mvc = MockMvcBuilders.webAppContextSetup(context)
                .addFilters(springSecurityFilterChain)
                .build();
    }

    @Test
    void registerAndRefreshFlowIssuesValidTokens() throws Exception {
        String email = "auth+" + System.nanoTime() + "@test.local";

        MvcResult registerResult = mvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "email": "%s",
                                  "password": "secret123",
                                  "username": "auth-tester",
                                  "phone": "5551234567"
                                }
                                """.formatted(email)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.token").isString())
                .andExpect(jsonPath("$.data.refreshToken").isString())
                .andExpect(jsonPath("$.data.user.email").value(email))
                .andReturn();

        Map<String, Object> registerResponse = objectMapper.readValue(
                registerResult.getResponse().getContentAsString(),
                new TypeReference<>() {
                }
        );
        Map<String, Object> registerData = castMap(registerResponse.get("data"));
        Map<String, Object> registerUser = castMap(registerData.get("user"));

        Long userId = ((Number) registerUser.get("id")).longValue();
        String accessToken = registerData.get("token").toString();
        String refreshToken = registerData.get("refreshToken").toString();

        assertThat(tokenService.validateAccessToken(accessToken)).isEqualTo(userId);
        assertThat(tokenService.validateRefreshToken(refreshToken)).isEqualTo(userId);

        MvcResult refreshResult = mvc.perform(post("/api/auth/refresh")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "refreshToken": "%s"
                                }
                                """.formatted(refreshToken)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.token").isString())
                .andExpect(jsonPath("$.data.refreshToken").isString())
                .andExpect(jsonPath("$.data.user.id").value(userId))
                .andExpect(jsonPath("$.data.user.email").value(email))
                .andReturn();

        Map<String, Object> refreshResponse = objectMapper.readValue(
                refreshResult.getResponse().getContentAsString(),
                new TypeReference<>() {
                }
        );
        Map<String, Object> refreshData = castMap(refreshResponse.get("data"));

        assertThat(tokenService.validateAccessToken(refreshData.get("token").toString())).isEqualTo(userId);
        assertThat(tokenService.validateRefreshToken(refreshData.get("refreshToken").toString())).isEqualTo(userId);
    }

    @Test
    void invalidRefreshTokenReturnsUnauthorized() throws Exception {
        mvc.perform(post("/api/auth/refresh")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "refreshToken": "not-a-valid-token"
                                }
                                """))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.message").value("Refresh token is invalid or expired"));
    }

    @Test
    void invalidBearerTokenReturnsUnauthorized() throws Exception {
        mvc.perform(get("/api/reports/mine")
                        .param("userId", "1")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer invalid.token.value"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.message").value("Access token is invalid or expired"));
    }

    @SuppressWarnings("unchecked")
    private Map<String, Object> castMap(Object value) {
        return (Map<String, Object>) value;
    }
}
