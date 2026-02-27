package com.elifkavurga.backend.common;

import lombok.Builder;
import lombok.Getter;

import java.time.Instant;

@Getter
@Builder
public class ApiResponse<T> {
    @Builder.Default
    private final Instant timestamp = Instant.now();
    private final boolean success;
    private final String message;
    private final T data;
}
