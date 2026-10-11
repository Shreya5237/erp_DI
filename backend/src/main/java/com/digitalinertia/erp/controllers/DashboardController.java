package com.digitalinertia.erp.controllers;

import com.digitalinertia.erp.common.ApiResponse;
import com.digitalinertia.erp.dto.dashboard.DashboardAlertDto;
import com.digitalinertia.erp.dto.dashboard.DashboardKpiDto;
import com.digitalinertia.erp.dto.dashboard.TaskOverviewDto;
import com.digitalinertia.erp.services.DashboardService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/dashboard")
public class DashboardController {

    private final DashboardService dashboardService;

    public DashboardController(DashboardService dashboardService) {
        this.dashboardService = dashboardService;
    }

    @GetMapping("/kpis")
    public ResponseEntity<ApiResponse<DashboardKpiDto>> getKpis() {
        return ResponseEntity.ok(ApiResponse.success(dashboardService.getKpis(), "KPIs retrieved successfully"));
    }

    @GetMapping("/alerts")
    public ResponseEntity<ApiResponse<List<DashboardAlertDto>>> getAlerts() {
        return ResponseEntity.ok(ApiResponse.success(dashboardService.getActiveAlerts(), "Active threshold alerts retrieved"));
    }

    @GetMapping("/tasks-breakdown")
    public ResponseEntity<ApiResponse<TaskOverviewDto>> getTasksBreakdown() {
        return ResponseEntity.ok(ApiResponse.success(dashboardService.getTaskOverview(), "Task overview retrieved successfully"));
    }
}
