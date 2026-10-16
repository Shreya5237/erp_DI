package com.digitalinertia.erp.services;

import com.digitalinertia.erp.common.ApiException;
import com.digitalinertia.erp.entities.SalesActivityEntity;
import com.digitalinertia.erp.repositories.SalesActivityRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Service
@Transactional(readOnly = true)
public class SalesActivityService {

    private final SalesActivityRepository activityRepository;

    public SalesActivityService(SalesActivityRepository activityRepository) {
        this.activityRepository = activityRepository;
    }

    public List<SalesActivityEntity> getAll(String leadId, String performedById) {
        if (leadId != null && !leadId.isBlank()) {
            return activityRepository.findByLeadIdOrderByScheduledAtDesc(leadId);
        }
        if (performedById != null && !performedById.isBlank()) {
            return activityRepository.findByPerformedByIdOrderByScheduledAtDesc(performedById);
        }
        return activityRepository.findTop20ByOrderByScheduledAtDesc();
    }

    public SalesActivityEntity getById(String id) {
        return activityRepository.findById(id)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Sales activity not found with id: " + id));
    }

    @Transactional
    public SalesActivityEntity create(SalesActivityEntity activity) {
        if (activity.getId() == null || activity.getId().isBlank()) {
            activity.setId("ACT-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase());
        }
        if (activity.getScheduledAt() == null) {
            activity.setScheduledAt(Instant.now());
        }
        activity.setCreatedAt(Instant.now());
        return activityRepository.save(activity);
    }

    @Transactional
    public SalesActivityEntity completeActivity(String id, String outcome) {
        SalesActivityEntity activity = getById(id);
        activity.setCompleted(true);
        if (outcome != null && !outcome.isBlank()) {
            activity.setOutcome(outcome);
        }
        return activityRepository.save(activity);
    }

    public List<SalesActivityEntity> getOverdueActivities() {
        return activityRepository.findOverdueActivities(Instant.now());
    }
}
