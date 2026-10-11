package com.digitalinertia.erp.repositories;

import com.digitalinertia.erp.entities.InternDailyUpdateEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface InternDailyUpdateRepository extends JpaRepository<InternDailyUpdateEntity, Long> {
    List<InternDailyUpdateEntity> findByInternIdOrderByUpdateDateDesc(String internId);
    Optional<InternDailyUpdateEntity> findByInternIdAndUpdateDate(String internId, LocalDate updateDate);
}
