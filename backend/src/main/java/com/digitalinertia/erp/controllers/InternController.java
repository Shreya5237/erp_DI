package com.digitalinertia.erp.controllers;

import com.digitalinertia.erp.common.ApiResponse;
import com.digitalinertia.erp.entities.InternBatchEntity;
import com.digitalinertia.erp.entities.InternDailyUpdateEntity;
import com.digitalinertia.erp.entities.InternEntity;
import com.digitalinertia.erp.entities.enums.InternDecision;
import com.digitalinertia.erp.services.InternService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/interns")
public class InternController {

    private final InternService internService;

    public InternController(InternService internService) {
        this.internService = internService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<InternEntity>>> getAll(
            @RequestParam(required = false) String batchId,
            @RequestParam(required = false) String pocId,
            @RequestParam(required = false) InternDecision decision) {
        return ResponseEntity.ok(ApiResponse.success(internService.getAll(batchId, pocId, decision), "Interns retrieved"));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<InternEntity>> getById(@PathVariable String id) {
        return ResponseEntity.ok(ApiResponse.success(internService.getById(id), "Intern retrieved"));
    }

    @PatchMapping("/{id}/decision")
    @PreAuthorize("hasAnyRole('ROLE_CEO', 'ROLE_POC')")
    public ResponseEntity<ApiResponse<InternEntity>> updateDecision(
            @PathVariable String id,
            @RequestParam InternDecision decision) {
        return ResponseEntity.ok(ApiResponse.success(internService.updateDecision(id, decision), "Intern decision updated"));
    }

    @GetMapping("/batches")
    public ResponseEntity<ApiResponse<List<InternBatchEntity>>> getBatches() {
        return ResponseEntity.ok(ApiResponse.success(internService.getAllBatches(), "Intern batches retrieved"));
    }

    @GetMapping("/{id}/daily-updates")
    public ResponseEntity<ApiResponse<List<InternDailyUpdateEntity>>> getDailyUpdates(@PathVariable String id) {
        return ResponseEntity.ok(ApiResponse.success(internService.getDailyUpdates(id), "Daily updates retrieved"));
    }

    @PostMapping("/{id}/daily-updates")
    public ResponseEntity<ApiResponse<InternDailyUpdateEntity>> addDailyUpdate(
            @PathVariable String id,
            @RequestBody InternDailyUpdateEntity update) {
        return ResponseEntity.ok(ApiResponse.success(internService.addDailyUpdate(id, update), "Daily update recorded"));
    }
}
