package com.digitalinertia.erp.controllers;

import com.digitalinertia.erp.common.ApiResponse;
import com.digitalinertia.erp.dto.employee.EmployeeUpsertRequest;
import com.digitalinertia.erp.entities.EmployeeEntity;
import com.digitalinertia.erp.services.EmployeeService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/employees")
public class EmployeeController {

    private final EmployeeService employeeService;

    public EmployeeController(EmployeeService employeeService) {
        this.employeeService = employeeService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<EmployeeEntity>>> getAll(
            @RequestParam(required = false, defaultValue = "true") Boolean activeOnly) {
        return ResponseEntity.ok(ApiResponse.success(employeeService.getAll(activeOnly), "Employees retrieved"));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<EmployeeEntity>> getById(@PathVariable String id) {
        return ResponseEntity.ok(ApiResponse.success(employeeService.getById(id), "Employee retrieved"));
    }

    @GetMapping("/pocs")
    public ResponseEntity<ApiResponse<List<EmployeeEntity>>> getPocs() {
        return ResponseEntity.ok(ApiResponse.success(employeeService.getPocs(), "POC employees retrieved"));
    }

    @GetMapping("/department/{departmentId}")
    public ResponseEntity<ApiResponse<List<EmployeeEntity>>> getByDepartment(@PathVariable String departmentId) {
        return ResponseEntity.ok(ApiResponse.success(employeeService.getByDepartment(departmentId), "Employees in department retrieved"));
    }

    @GetMapping("/subdepartment/{subDepartmentId}")
    public ResponseEntity<ApiResponse<List<EmployeeEntity>>> getBySubDepartment(@PathVariable String subDepartmentId) {
        return ResponseEntity.ok(ApiResponse.success(employeeService.getBySubDepartment(subDepartmentId), "Employees in subcategory retrieved"));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<EmployeeEntity>> create(@Valid @RequestBody EmployeeUpsertRequest request) {
        EmployeeEntity created = employeeService.create(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(created, "Employee created successfully"));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<EmployeeEntity>> update(
            @PathVariable String id,
            @Valid @RequestBody EmployeeUpsertRequest request) {
        EmployeeEntity updated = employeeService.update(id, request);
        return ResponseEntity.ok(ApiResponse.success(updated, "Employee updated successfully"));
    }
}
