package com.digitalinertia.erp.repositories;

import com.digitalinertia.erp.entities.EmployeeEntity;
import com.digitalinertia.erp.entities.enums.RoleCategory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface EmployeeRepository extends JpaRepository<EmployeeEntity, String> {
    Optional<EmployeeEntity> findByEmail(String email);
    List<EmployeeEntity> findByActiveTrue();
    List<EmployeeEntity> findByCategory(RoleCategory category);
    List<EmployeeEntity> findByTeamId(String teamId);
    List<EmployeeEntity> findByDepartmentId(String departmentId);
    List<EmployeeEntity> findBySubDepartmentId(String subDepartmentId);
    List<EmployeeEntity> findByPocTrue();
    long countByActiveTrue();
    long countByDepartmentId(String departmentId);
}
