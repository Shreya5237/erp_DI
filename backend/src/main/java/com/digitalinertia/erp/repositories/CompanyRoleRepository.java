package com.digitalinertia.erp.repositories;

import com.digitalinertia.erp.entities.CompanyRoleEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CompanyRoleRepository extends JpaRepository<CompanyRoleEntity, String> {
    List<CompanyRoleEntity> findByActiveTrue();
}
