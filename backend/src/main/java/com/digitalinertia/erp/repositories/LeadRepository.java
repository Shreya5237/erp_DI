package com.digitalinertia.erp.repositories;

import com.digitalinertia.erp.entities.LeadEntity;
import com.digitalinertia.erp.entities.enums.LeadStage;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface LeadRepository extends JpaRepository<LeadEntity, String> {
    List<LeadEntity> findByActiveTrue();
    List<LeadEntity> findByStage(LeadStage stage);
    List<LeadEntity> findByOwnerId(String ownerId);

    @Query("SELECT l FROM LeadEntity l WHERE l.active = true AND l.stage != com.digitalinertia.erp.entities.enums.LeadStage.lost")
    List<LeadEntity> findActiveLeads();

    @Query("SELECT COUNT(l) FROM LeadEntity l WHERE l.active = true AND l.stage != com.digitalinertia.erp.entities.enums.LeadStage.lost")
    long countActiveLeads();

    @Query("SELECT l FROM LeadEntity l WHERE l.stage NOT IN (com.digitalinertia.erp.entities.enums.LeadStage.won, com.digitalinertia.erp.entities.enums.LeadStage.lost) AND l.nextFollowUp < :today")
    List<LeadEntity> findMissedFollowUps(@Param("today") LocalDate today);

    @org.springframework.data.jpa.repository.Modifying
    @Query(value = "UPDATE leads SET stage = cast(:stage as lead_stage_enum), updated_at = NOW() WHERE id = :id", nativeQuery = true)
    int updateStageNative(@Param("id") String id, @Param("stage") String stage);
}
