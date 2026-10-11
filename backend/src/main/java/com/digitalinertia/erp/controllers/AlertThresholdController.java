package com.digitalinertia.erp.controllers;

import com.digitalinertia.erp.common.ApiResponse;
import com.digitalinertia.erp.entities.AlertThresholdSettingsEntity;
import com.digitalinertia.erp.services.AlertThresholdService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/settings/thresholds")
public class AlertThresholdController {

    private final AlertThresholdService service;

    public AlertThresholdController(AlertThresholdService service) {
        this.service = service;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<AlertThresholdSettingsEntity>> getSettings() {
        return ResponseEntity.ok(ApiResponse.success(service.getSettings(), "Alert thresholds retrieved"));
    }

    @PutMapping
    @PreAuthorize("hasRole('ROLE_CEO')")
    public ResponseEntity<ApiResponse<AlertThresholdSettingsEntity>> updateSettings(
            @RequestBody AlertThresholdSettingsEntity settings) {
        return ResponseEntity.ok(ApiResponse.success(service.updateSettings(settings), "Alert thresholds updated successfully"));
    }
}
