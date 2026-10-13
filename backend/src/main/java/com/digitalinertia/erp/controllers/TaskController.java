package com.digitalinertia.erp.controllers;

import com.digitalinertia.erp.common.ApiResponse;
import com.digitalinertia.erp.entities.TaskEntity;
import com.digitalinertia.erp.entities.enums.AssigneeType;
import com.digitalinertia.erp.entities.enums.TaskPriority;
import com.digitalinertia.erp.entities.enums.TaskStatus;
import com.digitalinertia.erp.services.TaskService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/tasks")
public class TaskController {

    private final TaskService taskService;

    public TaskController(TaskService taskService) {
        this.taskService = taskService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<TaskEntity>>> getAll(
            @RequestParam(required = false) TaskStatus status,
            @RequestParam(required = false) TaskPriority priority,
            @RequestParam(required = false) String assignedToId,
            @RequestParam(required = false) AssigneeType assigneeType,
            @RequestParam(required = false) String projectId) {
        return ResponseEntity.ok(ApiResponse.success(
                taskService.getAll(status, priority, assignedToId, assigneeType, projectId),
                "Tasks retrieved successfully"));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<TaskEntity>> getById(@PathVariable String id) {
        return ResponseEntity.ok(ApiResponse.success(taskService.getById(id), "Task retrieved"));
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('CEO', 'POC', 'ROLE_CEO', 'ROLE_POC')")
    public ResponseEntity<ApiResponse<TaskEntity>> create(@RequestBody TaskEntity task) {
        return ResponseEntity.ok(ApiResponse.success(taskService.create(task), "Task created successfully"));
    }

    @PatchMapping("/{id}/status")
    public ResponseEntity<ApiResponse<TaskEntity>> updateStatus(
            @PathVariable String id,
            @RequestParam TaskStatus status) {
        return ResponseEntity.ok(ApiResponse.success(taskService.updateStatus(id, status), "Task status updated"));
    }

    @PatchMapping("/{id}/review")
    public ResponseEntity<ApiResponse<TaskEntity>> setAwaitingReview(
            @PathVariable String id,
            @RequestParam boolean awaitingReview) {
        return ResponseEntity.ok(ApiResponse.success(taskService.setAwaitingReview(id, awaitingReview), "Task review status updated"));
    }
}
