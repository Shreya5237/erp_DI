package com.digitalinertia.erp.repositories;

import com.digitalinertia.erp.entities.AlertThresholdSettingsEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface AlertThresholdSettingsRepository extends JpaRepository<AlertThresholdSettingsEntity, Integer> {
}
