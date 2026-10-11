package com.digitalinertia.erp.dto.auth;

public class LoginResponse {
    private String token;
    private String tokenType = "Bearer";
    private long expiresInMs;
    private AuthUserDto user;

    public LoginResponse() {}

    public LoginResponse(String token, long expiresInMs, AuthUserDto user) {
        this.token = token;
        this.tokenType = "Bearer";
        this.expiresInMs = expiresInMs;
        this.user = user;
    }

    public String getToken() { return token; }
    public void setToken(String token) { this.token = token; }

    public String getTokenType() { return tokenType; }
    public void setTokenType(String tokenType) { this.tokenType = tokenType; }

    public long getExpiresInMs() { return expiresInMs; }
    public void setExpiresInMs(long expiresInMs) { this.expiresInMs = expiresInMs; }

    public AuthUserDto getUser() { return user; }
    public void setUser(AuthUserDto user) { this.user = user; }
}
