package com.digitalinertia.erp.controllers;

import com.digitalinertia.erp.common.ApiResponse;
import com.digitalinertia.erp.entities.LeadEntity;
import com.digitalinertia.erp.entities.enums.LeadStage;
import com.digitalinertia.erp.services.LeadService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/leads")
public class LeadController {

    private final LeadService leadService;

    public LeadController(LeadService leadService) {
        this.leadService = leadService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<LeadEntity>>> getAll(
            @RequestParam(required = false) LeadStage stage,
            @RequestParam(required = false) String ownerId) {
        return ResponseEntity.ok(ApiResponse.success(leadService.getAll(stage, ownerId), "Leads retrieved"));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<LeadEntity>> getById(@PathVariable String id) {
        return ResponseEntity.ok(ApiResponse.success(leadService.getById(id), "Lead retrieved"));
    }

    @PatchMapping("/{id}/stage")
    @PreAuthorize("hasAnyRole('CEO', 'POC', 'SALES', 'ROLE_CEO', 'ROLE_POC', 'ROLE_SALES')")
    public ResponseEntity<ApiResponse<LeadEntity>> updateStage(
            @PathVariable String id,
            @RequestParam LeadStage stage) {
        return ResponseEntity.ok(ApiResponse.success(leadService.updateStage(id, stage), "Lead stage updated"));
    }
}
