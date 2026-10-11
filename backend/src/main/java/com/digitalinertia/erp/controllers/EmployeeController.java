package com.digitalinertia.erp.controllers;

import com.digitalinertia.erp.common.ApiResponse;
import com.digitalinertia.erp.entities.EmployeeEntity;
import com.digitalinertia.erp.services.EmployeeService;
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
}
