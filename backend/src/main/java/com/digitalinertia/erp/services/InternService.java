package com.digitalinertia.erp.services;

import com.digitalinertia.erp.common.ApiException;
import com.digitalinertia.erp.entities.InternBatchEntity;
import com.digitalinertia.erp.entities.InternDailyUpdateEntity;
import com.digitalinertia.erp.entities.InternEntity;
import com.digitalinertia.erp.entities.enums.InternDecision;
import com.digitalinertia.erp.repositories.InternBatchRepository;
import com.digitalinertia.erp.repositories.InternDailyUpdateRepository;
import com.digitalinertia.erp.repositories.InternRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDate;
import java.util.List;

@Service
@Transactional(readOnly = true)
public class InternService {

    private final InternRepository internRepository;
    private final InternBatchRepository batchRepository;
    private final InternDailyUpdateRepository dailyUpdateRepository;

    public InternService(
            InternRepository internRepository,
            InternBatchRepository batchRepository,
            InternDailyUpdateRepository dailyUpdateRepository) {
        this.internRepository = internRepository;
        this.batchRepository = batchRepository;
        this.dailyUpdateRepository = dailyUpdateRepository;
    }

    public List<InternEntity> getAll(String batchId, String pocId, InternDecision decision) {
        if (batchId != null && !batchId.isBlank()) {
            return internRepository.findByBatchId(batchId);
        }
        if (pocId != null && !pocId.isBlank()) {
            return internRepository.findByAssignedPocId(pocId);
        }
        if (decision != null) {
            return internRepository.findByFinalDecision(decision);
        }
        return internRepository.findAll();
    }

    public InternEntity getById(String id) {
        return internRepository.findById(id)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Intern not found with id: " + id));
    }

    @Transactional
    public InternEntity updateDecision(String id, InternDecision decision) {
        InternEntity intern = getById(id);
        intern.setFinalDecision(decision);
        intern.setUpdatedAt(Instant.now());
        return internRepository.save(intern);
    }

    public List<InternBatchEntity> getAllBatches() {
        return batchRepository.findAll();
    }

    public List<InternDailyUpdateEntity> getDailyUpdates(String internId) {
        return dailyUpdateRepository.findByInternIdOrderByUpdateDateDesc(internId);
    }

    @Transactional
    public InternDailyUpdateEntity addDailyUpdate(String internId, InternDailyUpdateEntity update) {
        getById(internId); // verify intern exists
        update.setInternId(internId);
        if (update.getUpdateDate() == null) {
            update.setUpdateDate(LocalDate.now());
        }
        return dailyUpdateRepository.save(update);
    }
}
