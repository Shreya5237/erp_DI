package com.digitalinertia.erp.services;

import com.digitalinertia.erp.common.ApiException;
import com.digitalinertia.erp.entities.EmployeeEntity;
import com.digitalinertia.erp.repositories.EmployeeRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional(readOnly = true)
public class EmployeeService {

    private final EmployeeRepository employeeRepository;

    public EmployeeService(EmployeeRepository employeeRepository) {
        this.employeeRepository = employeeRepository;
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
}
