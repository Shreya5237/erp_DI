package com.digitalinertia.erp.controllers;

import com.digitalinertia.erp.common.ApiResponse;
import com.digitalinertia.erp.dto.auth.AuthUserDto;
import com.digitalinertia.erp.dto.auth.LoginRequest;
import com.digitalinertia.erp.dto.auth.LoginResponse;
import com.digitalinertia.erp.security.JwtTokenProvider;
import com.digitalinertia.erp.security.UserPrincipal;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
public class AuthController {

    private final AuthenticationManager authenticationManager;
    private final JwtTokenProvider tokenProvider;
    private final long expirationMs;

    public AuthController(
            AuthenticationManager authenticationManager,
            JwtTokenProvider tokenProvider,
            @Value("${app.jwt.expiration-ms:86400000}") long expirationMs) {
        this.authenticationManager = authenticationManager;
        this.tokenProvider = tokenProvider;
        this.expirationMs = expirationMs;
    }

    @PostMapping("/login")
    public ResponseEntity<ApiResponse<LoginResponse>> login(@Valid @RequestBody LoginRequest request) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword())
        );

        UserPrincipal principal = (UserPrincipal) authentication.getPrincipal();
        String token = tokenProvider.generateToken(principal);

        AuthUserDto userDto = new AuthUserDto(
                principal.getId(),
                principal.getEmail(),
                principal.getFullName(),
                principal.getRole(),
                principal.getEmployeeId()
        );

        LoginResponse loginResponse = new LoginResponse(token, expirationMs, userDto);
        return ResponseEntity.ok(ApiResponse.success(loginResponse, "Authentication successful"));
    }

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<AuthUserDto>> getCurrentUser(@AuthenticationPrincipal UserPrincipal principal) {
        if (principal == null) {
            return ResponseEntity.status(401).body(ApiResponse.error(401, "Unauthorized", "Not logged in"));
        }

        AuthUserDto userDto = new AuthUserDto(
                principal.getId(),
                principal.getEmail(),
                principal.getFullName(),
                principal.getRole(),
                principal.getEmployeeId()
        );

        return ResponseEntity.ok(ApiResponse.success(userDto, "User profile retrieved"));
    }
}
