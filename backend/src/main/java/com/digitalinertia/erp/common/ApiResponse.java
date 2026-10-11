package com.digitalinertia.erp.common;

import java.time.Instant;

public record ApiResponse<T>(
    boolean success,
    String message,
    T data,
    Instant timestamp
) {
    public static <T> ApiResponse<T> success(T data) {
        return new ApiResponse<>(true, "Operation successful", data, Instant.now());
    }

    public static <T> ApiResponse<T> success(T data, String message) {
        return new ApiResponse<>(true, message, data, Instant.now());
    }

    public static <T> ApiResponse<T> success(String message, T data) {
        return new ApiResponse<>(true, message, data, Instant.now());
    }

    public static <T> ApiResponse<T> error(String message) {
        return new ApiResponse<>(false, message, null, Instant.now());
    }

    public static <T> ApiResponse<T> error(int code, String error, String message) {
        return new ApiResponse<>(false, message, null, Instant.now());
    }
}
