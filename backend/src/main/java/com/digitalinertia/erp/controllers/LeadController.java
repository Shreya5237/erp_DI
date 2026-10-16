package com.digitalinertia.erp.controllers;

import com.digitalinertia.erp.common.ApiResponse;
import com.digitalinertia.erp.dto.sales.LeadCreateDto;
import com.digitalinertia.erp.dto.sales.SalesDashboardSummaryDto;
import com.digitalinertia.erp.dto.sales.StageTransitionDto;
import com.digitalinertia.erp.entities.LeadEntity;
import com.digitalinertia.erp.entities.SalesActivityEntity;
import com.digitalinertia.erp.entities.enums.LeadStage;
import com.digitalinertia.erp.security.UserPrincipal;
import com.digitalinertia.erp.services.LeadService;
import com.digitalinertia.erp.services.SalesActivityService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/leads")
public class LeadController {

    private final LeadService leadService;
    private final SalesActivityService activityService;

    public LeadController(LeadService leadService, SalesActivityService activityService) {
        this.leadService = leadService;
        this.activityService = activityService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<LeadEntity>>> getAll(
            @RequestParam(required = false) LeadStage stage,
            @RequestParam(required = false) String ownerId) {
        return ResponseEntity.ok(ApiResponse.success(leadService.getAll(stage, ownerId), "Leads retrieved"));
    }

    @GetMapping("/dashboard-summary")
    public ResponseEntity<ApiResponse<SalesDashboardSummaryDto>> getDashboardSummary() {
        return ResponseEntity.ok(ApiResponse.success(leadService.getDashboardSummary(), "Sales dashboard summary retrieved"));
    }

    @GetMapping("/check-duplicate")
    public ResponseEntity<ApiResponse<Map<String, Object>>> checkDuplicate(
            @RequestParam(required = false) String companyName,
            @RequestParam(required = false) String email) {
        boolean duplicate = leadService.checkDuplicate(companyName, email);
        return ResponseEntity.ok(ApiResponse.success(
                Map.of("duplicate", duplicate, "companyName", companyName != null ? companyName : "", "email", email != null ? email : ""),
                duplicate ? "Duplicate lead detected" : "Lead is unique"
        ));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<LeadEntity>> getById(@PathVariable String id) {
        return ResponseEntity.ok(ApiResponse.success(leadService.getById(id), "Lead retrieved"));
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('CEO', 'POC', 'SALES', 'SALES_MARKETING', 'ROLE_CEO', 'ROLE_POC', 'ROLE_SALES', 'ROLE_SALES_MARKETING')")
    public ResponseEntity<ApiResponse<LeadEntity>> create(
            @RequestBody LeadCreateDto dto,
            @AuthenticationPrincipal UserPrincipal principal) {
        String performer = principal != null ? principal.getFullName() : "Sales Representative";
        return ResponseEntity.ok(ApiResponse.success(leadService.create(dto, performer), "Lead created successfully"));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('CEO', 'POC', 'SALES', 'SALES_MARKETING', 'ROLE_CEO', 'ROLE_POC', 'ROLE_SALES', 'ROLE_SALES_MARKETING')")
    public ResponseEntity<ApiResponse<LeadEntity>> update(
            @PathVariable String id,
            @RequestBody LeadEntity updateData,
            @AuthenticationPrincipal UserPrincipal principal) {
        String performer = principal != null ? principal.getFullName() : "Sales Representative";
        return ResponseEntity.ok(ApiResponse.success(leadService.update(id, updateData, performer), "Lead updated successfully"));
    }

    @PostMapping("/{id}/transition")
    @PreAuthorize("hasAnyRole('CEO', 'POC', 'SALES', 'SALES_MARKETING', 'ROLE_CEO', 'ROLE_POC', 'ROLE_SALES', 'ROLE_SALES_MARKETING')")
    public ResponseEntity<ApiResponse<LeadEntity>> transition(
            @PathVariable String id,
            @RequestBody StageTransitionDto dto,
            @AuthenticationPrincipal UserPrincipal principal) {
        String performer = principal != null ? principal.getFullName() : "Sales Representative";
        return ResponseEntity.ok(ApiResponse.success(leadService.transitionStage(id, dto, performer), "Lead stage transitioned successfully"));
    }

    @PatchMapping("/{id}/stage")
    @PreAuthorize("hasAnyRole('CEO', 'POC', 'SALES', 'SALES_MARKETING', 'ROLE_CEO', 'ROLE_POC', 'ROLE_SALES', 'ROLE_SALES_MARKETING')")
    public ResponseEntity<ApiResponse<LeadEntity>> updateStage(
            @PathVariable String id,
            @RequestParam LeadStage stage) {
        return ResponseEntity.ok(ApiResponse.success(leadService.updateStage(id, stage), "Lead stage updated"));
    }

    // Sales activities endpoints
    @GetMapping("/activities")
    public ResponseEntity<ApiResponse<List<SalesActivityEntity>>> getActivities(
            @RequestParam(required = false) String leadId,
            @RequestParam(required = false) String performedById) {
        return ResponseEntity.ok(ApiResponse.success(activityService.getAll(leadId, performedById), "Sales activities retrieved"));
    }

    @PostMapping("/activities")
    @PreAuthorize("hasAnyRole('CEO', 'POC', 'SALES', 'SALES_MARKETING', 'ROLE_CEO', 'ROLE_POC', 'ROLE_SALES', 'ROLE_SALES_MARKETING')")
    public ResponseEntity<ApiResponse<SalesActivityEntity>> createActivity(
            @RequestBody SalesActivityEntity activity,
            @AuthenticationPrincipal UserPrincipal principal) {
        if (principal != null) {
            activity.setPerformedById(principal.getEmployeeId());
            activity.setPerformedByName(principal.getFullName());
        }
        return ResponseEntity.ok(ApiResponse.success(activityService.create(activity), "Activity logged successfully"));
    }

    @PatchMapping("/activities/{id}/complete")
    public ResponseEntity<ApiResponse<SalesActivityEntity>> completeActivity(
            @PathVariable String id,
            @RequestParam(required = false) String outcome) {
        return ResponseEntity.ok(ApiResponse.success(activityService.completeActivity(id, outcome), "Activity completed"));
    }
}
