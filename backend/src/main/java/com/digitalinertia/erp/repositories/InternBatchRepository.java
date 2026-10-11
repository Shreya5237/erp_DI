package com.digitalinertia.erp.repositories;

import com.digitalinertia.erp.entities.InternBatchEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface InternBatchRepository extends JpaRepository<InternBatchEntity, String> {
    List<InternBatchEntity> findByActiveTrue();
}
