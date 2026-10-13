package com.digitalinertia.erp.repositories;

import com.digitalinertia.erp.entities.DepartmentEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface DepartmentRepository extends JpaRepository<DepartmentEntity, String> {

    List<DepartmentEntity> findByParentIdIsNullAndActiveTrueOrderByNameAsc();

    List<DepartmentEntity> findByParentIdAndActiveTrueOrderByNameAsc(String parentId);

    Optional<DepartmentEntity> findByNameIgnoreCaseAndParentIdIsNull(String name);

    Optional<DepartmentEntity> findByCodeIgnoreCase(String code);

    long countByParentIdIsNull();
}
