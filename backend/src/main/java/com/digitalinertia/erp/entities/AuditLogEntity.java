package com.digitalinertia.erp.entities;

import jakarta.persistence.*;
import java.time.Instant;

@Entity
@Table(name = "audit_logs")
public class AuditLogEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 100)
    private String action;

    @Column(nullable = false, length = 50)
    private String module;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String details;

    @Column(name = "performed_by", nullable = false, length = 100)
    private String performedBy = "Laven Lokesh (CEO)";

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    public AuditLogEntity() {}

    public AuditLogEntity(String action, String module, String details, String performedBy) {
        this.action = action;
        this.module = module;
        this.details = details;
        this.performedBy = performedBy;
        this.createdAt = Instant.now();
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getAction() { return action; }
    public void setAction(String action) { this.action = action; }

    public String getModule() { return module; }
    public void setModule(String module) { this.module = module; }

    public String getDetails() { return details; }
    public void setDetails(String details) { this.details = details; }

    public String getPerformedBy() { return performedBy; }
    public void setPerformedBy(String performedBy) { this.performedBy = performedBy; }

    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }
}
