package com.digitalinertia.erp.repositories;

import com.digitalinertia.erp.entities.InternEntity;
import com.digitalinertia.erp.entities.enums.InternDecision;
import com.digitalinertia.erp.entities.enums.RoleCategory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface InternRepository extends JpaRepository<InternEntity, String> {
    List<InternEntity> findByActiveTrue();
    List<InternEntity> findByBatchId(String batchId);
    List<InternEntity> findByAssignedPocId(String assignedPocId);
    List<InternEntity> findByCategory(RoleCategory category);
    List<InternEntity> findByFinalDecision(InternDecision decision);
    List<InternEntity> findByMissedUpdatesDaysGreaterThanEqual(int days);
    long countByActiveTrue();
}
