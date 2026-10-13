package com.digitalinertia.erp.services;

import com.digitalinertia.erp.common.ApiException;
import com.digitalinertia.erp.dto.employee.EmployeeUpsertRequest;
import com.digitalinertia.erp.entities.EmployeeEntity;
import com.digitalinertia.erp.repositories.EmployeeRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Service
@Transactional(readOnly = true)
public class EmployeeService {

    private final EmployeeRepository employeeRepository;
    private final DepartmentService departmentService;

    public EmployeeService(EmployeeRepository employeeRepository, DepartmentService departmentService) {
        this.employeeRepository = employeeRepository;
        this.departmentService = departmentService;
    }

    public List<EmployeeEntity> getAll(Boolean activeOnly) {
        if (Boolean.TRUE.equals(activeOnly)) {
            return employeeRepository.findByActiveTrue();
        }
        return employeeRepository.findAll();
    }

    public EmployeeEntity getById(String id) {
        return employeeRepository.findById(id)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Employee not found with id: " + id));
    }

    public List<EmployeeEntity> getPocs() {
        return employeeRepository.findByPocTrue();
    }

    public List<EmployeeEntity> getByTeam(String teamId) {
        return employeeRepository.findByTeamId(teamId);
    }

    public List<EmployeeEntity> getByDepartment(String departmentId) {
        return employeeRepository.findByDepartmentId(departmentId);
    }

    public List<EmployeeEntity> getBySubDepartment(String subDepartmentId) {
        return employeeRepository.findBySubDepartmentId(subDepartmentId);
    }

    @Transactional
    public EmployeeEntity create(EmployeeUpsertRequest req) {
        // Validate department and subcategory hierarchy
        departmentService.validateDepartmentAssignment(req.getDepartmentId(), req.getSubDepartmentId());

        if (employeeRepository.findByEmail(req.getEmail()).isPresent()) {
            throw new ApiException(HttpStatus.CONFLICT, "Employee already exists with email: " + req.getEmail());
        }

        EmployeeEntity entity = new EmployeeEntity();
        entity.setId("EMP-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase());
        entity.setName(req.getName());
        entity.setEmail(req.getEmail());
        entity.setPhone(req.getPhone());
        entity.setRoleId(req.getRoleId());
        entity.setRoleTitle(req.getRoleTitle());
        entity.setTeamId(req.getTeamId());
        entity.setTeamName(req.getTeamName());
        entity.setCategory(req.getCategory());
        entity.setDepartmentId(req.getDepartmentId());
        entity.setSubDepartmentId(req.getSubDepartmentId());
        entity.setPoc(req.isPoc());
        entity.setMaxTaskCapacity(req.getMaxTaskCapacity());
        entity.setJoinedDate(LocalDate.now());
        entity.setLastActiveAt(Instant.now());
        entity.setCreatedAt(Instant.now());
        entity.setUpdatedAt(Instant.now());

        return employeeRepository.save(entity);
    }

    @Transactional
    public EmployeeEntity update(String id, EmployeeUpsertRequest req) {
        EmployeeEntity entity = getById(id);

        // Validate department and subcategory hierarchy
        departmentService.validateDepartmentAssignment(req.getDepartmentId(), req.getSubDepartmentId());

        employeeRepository.findByEmail(req.getEmail()).ifPresent(existing -> {
            if (!existing.getId().equals(id)) {
                throw new ApiException(HttpStatus.CONFLICT, "Email already in use by another employee: " + req.getEmail());
            }
        });

        entity.setName(req.getName());
        entity.setEmail(req.getEmail());
        entity.setPhone(req.getPhone());
        entity.setRoleId(req.getRoleId());
        entity.setRoleTitle(req.getRoleTitle());
        entity.setTeamId(req.getTeamId());
        entity.setTeamName(req.getTeamName());
        entity.setCategory(req.getCategory());
        entity.setDepartmentId(req.getDepartmentId());
        entity.setSubDepartmentId(req.getSubDepartmentId());
        entity.setPoc(req.isPoc());
        entity.setMaxTaskCapacity(req.getMaxTaskCapacity());
        entity.setUpdatedAt(Instant.now());

        return employeeRepository.save(entity);
    }
}
