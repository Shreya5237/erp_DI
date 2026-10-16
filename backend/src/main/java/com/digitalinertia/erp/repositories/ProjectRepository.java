package com.digitalinertia.erp.repositories;

import com.digitalinertia.erp.entities.ProjectEntity;
import com.digitalinertia.erp.entities.enums.ProjectStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ProjectRepository extends JpaRepository<ProjectEntity, String> {
    List<ProjectEntity> findByStatus(ProjectStatus status);
    List<ProjectEntity> findByOwnerId(String ownerId);
    List<ProjectEntity> findByHasBlockersTrue();
    List<ProjectEntity> findByClientNameIgnoreCase(String clientName);
    
    @Query("SELECT p FROM ProjectEntity p WHERE p.status IN ('planning', 'in_progress', 'on_hold')")
    List<ProjectEntity> findActiveProjects();

    @Query("SELECT COUNT(p) FROM ProjectEntity p WHERE p.status IN ('planning', 'in_progress', 'on_hold')")
    long countActiveProjects();
}
