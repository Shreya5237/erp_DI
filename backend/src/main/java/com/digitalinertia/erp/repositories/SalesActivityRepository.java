package com.digitalinertia.erp.repositories;

import com.digitalinertia.erp.entities.SalesActivityEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.List;

@Repository
public interface SalesActivityRepository extends JpaRepository<SalesActivityEntity, String> {
    List<SalesActivityEntity> findByLeadIdOrderByScheduledAtDesc(String leadId);
    List<SalesActivityEntity> findByPerformedByIdOrderByScheduledAtDesc(String performedById);
    List<SalesActivityEntity> findByActivityType(String activityType);

    @Query("SELECT a FROM SalesActivityEntity a WHERE a.completed = false AND a.scheduledAt < :now ORDER BY a.scheduledAt ASC")
    List<SalesActivityEntity> findOverdueActivities(@Param("now") Instant now);

    List<SalesActivityEntity> findTop20ByOrderByScheduledAtDesc();
}
