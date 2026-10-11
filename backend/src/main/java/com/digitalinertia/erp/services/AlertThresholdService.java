package com.digitalinertia.erp.services;

import com.digitalinertia.erp.entities.AlertThresholdSettingsEntity;
import com.digitalinertia.erp.repositories.AlertThresholdSettingsRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;

@Service
@Transactional(readOnly = true)
public class AlertThresholdService {

    private final AlertThresholdSettingsRepository repository;

    public AlertThresholdService(AlertThresholdSettingsRepository repository) {
        this.repository = repository;
    }

    public AlertThresholdSettingsEntity getSettings() {
        return repository.findById(1).orElseGet(() -> {
            AlertThresholdSettingsEntity def = new AlertThresholdSettingsEntity();
            def.setId(1);
            return def;
        });
    }

    @Transactional
    public AlertThresholdSettingsEntity updateSettings(AlertThresholdSettingsEntity newSettings) {
        AlertThresholdSettingsEntity existing = getSettings();
        existing.setTaskOverdueDays(newSettings.getTaskOverdueDays());
        existing.setInternMissedUpdateDays(newSettings.getInternMissedUpdateDays());
        existing.setProjectBehindSchedulePercent(newSettings.getProjectBehindSchedulePercent());
        existing.setEmployeeCapacityMaxTasks(newSettings.getEmployeeCapacityMaxTasks());
        existing.setInternLowScoreCutoff(newSettings.getInternLowScoreCutoff());
        existing.setUpdatedAt(Instant.now());
        return repository.save(existing);
    }
}
