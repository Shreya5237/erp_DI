package com.digitalinertia.erp.controllers;

import com.digitalinertia.erp.common.ApiResponse;
import com.digitalinertia.erp.dto.department.DepartmentDto;
import com.digitalinertia.erp.services.DepartmentService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/departments")
public class DepartmentController {

    private final DepartmentService departmentService;

    public DepartmentController(DepartmentService departmentService) {
        this.departmentService = departmentService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<DepartmentDto>>> getDepartmentTree() {
        List<DepartmentDto> tree = departmentService.getDepartmentTree();
        return ResponseEntity.ok(ApiResponse.success(tree, "Department hierarchy retrieved successfully"));
    }

    @GetMapping("/roots")
    public ResponseEntity<ApiResponse<List<DepartmentDto>>> getRootDepartments() {
        List<DepartmentDto> roots = departmentService.getRootDepartments();
        return ResponseEntity.ok(ApiResponse.success(roots, "Top-level departments retrieved successfully"));
    }

    @GetMapping("/{id}/subcategories")
    public ResponseEntity<ApiResponse<List<DepartmentDto>>> getSubcategories(@PathVariable String id) {
        List<DepartmentDto> subcategories = departmentService.getSubcategories(id);
        return ResponseEntity.ok(ApiResponse.success(subcategories, "Department subcategories retrieved successfully"));
    }
}
