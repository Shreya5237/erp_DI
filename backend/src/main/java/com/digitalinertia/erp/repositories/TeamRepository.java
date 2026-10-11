package com.digitalinertia.erp.repositories;

import com.digitalinertia.erp.entities.TeamEntity;
import com.digitalinertia.erp.entities.enums.RoleCategory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TeamRepository extends JpaRepository<TeamEntity, String> {
    List<TeamEntity> findByCategory(RoleCategory category);
}
