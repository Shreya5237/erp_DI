package com.digitalinertia.erp.services;

import com.digitalinertia.erp.common.ApiException;
import com.digitalinertia.erp.entities.LeadEntity;
import com.digitalinertia.erp.entities.enums.LeadStage;
import com.digitalinertia.erp.repositories.LeadRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;

@Service
@Transactional(readOnly = true)
public class LeadService {

    private final LeadRepository leadRepository;

    public LeadService(LeadRepository leadRepository) {
        this.leadRepository = leadRepository;
    }

    public List<LeadEntity> getAll(LeadStage stage, String ownerId) {
        if (stage != null) {
            return leadRepository.findByStage(stage);
        }
        if (ownerId != null && !ownerId.isBlank()) {
            return leadRepository.findByOwnerId(ownerId);
        }
        return leadRepository.findAll();
    }

    public LeadEntity getById(String id) {
        return leadRepository.findById(id)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Lead not found with id: " + id));
    }

    @Transactional
    public LeadEntity updateStage(String id, LeadStage stage) {
        LeadEntity lead = getById(id);
        lead.setStage(stage);
        lead.setUpdatedAt(Instant.now());
        return leadRepository.save(lead);
    }
}
