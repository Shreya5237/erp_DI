package com.digitalinertia.erp.controllers;

import com.digitalinertia.erp.common.ApiResponse;
import com.digitalinertia.erp.entities.ProjectEntity;
import com.digitalinertia.erp.entities.enums.ProjectStatus;
import com.digitalinertia.erp.services.ProjectService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/projects")
public class ProjectController {

    private final ProjectService projectService;

    public ProjectController(ProjectService projectService) {
        this.projectService = projectService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<ProjectEntity>>> getAll(
            @RequestParam(required = false) ProjectStatus status) {
        return ResponseEntity.ok(ApiResponse.success(projectService.getAll(status), "Projects retrieved"));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<ProjectEntity>> getById(@PathVariable String id) {
        return ResponseEntity.ok(ApiResponse.success(projectService.getById(id), "Project retrieved"));
    }
}
