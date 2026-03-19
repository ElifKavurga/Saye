package com.elifkavurga.backend.health;

import com.elifkavurga.backend.common.ApiResponse;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.Instant;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping({"/health", "/api/health"})
public class HealthController {

    private final JdbcTemplate jdbcTemplate;

    public HealthController(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @GetMapping
    public ApiResponse<Map<String, Object>> health() {
        return ApiResponse.<Map<String, Object>>builder()
                .success(true)
                .message("Backend is healthy")
                .timestamp(Instant.now())
                .data(Map.of(
                        "database", true,
                        "timestamp", Instant.now().toString()
                ))
                .build();
    }

    @GetMapping("/db")
    public ApiResponse<Map<String, Object>> databaseCheck() {
        Map<String, Object> data = new HashMap<>();
        try {
            Integer check = jdbcTemplate.queryForObject("SELECT 1", Integer.class);
            data.put("database", check != null && check == 1 ? "UP" : "DOWN");
            data.put("status", "UP");
        } catch (Exception ex) {
            data.put("database", "DOWN");
            data.put("status", "DOWN");
        }
        return ApiResponse.<Map<String, Object>>builder()
                .success("UP".equals(data.get("status")))
                .message("Database check: " + data.get("status"))
                .timestamp(Instant.now())
                .data(data)
                .build();
    }
}
