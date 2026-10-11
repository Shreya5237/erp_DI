package com.digitalinertia.erp.entities;

import com.digitalinertia.erp.entities.enums.InternDecision;
import com.digitalinertia.erp.entities.enums.RoleCategory;
import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;

@Entity
@Table(name = "interns")
public class InternEntity {

    @Id
    @Column(length = 32)
    private String id;

    @Column(nullable = false, length = 100)
    private String name;

    @Column(nullable = false, unique = true, length = 150)
    private String email;

    @Column(length = 30)
    private String phone;

    @Column(nullable = false, length = 150)
    private String college;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, columnDefinition = "role_category_enum")
    private RoleCategory category = RoleCategory.technical;

    @Column(nullable = false, length = 100)
    private String domain;

    @Column(name = "team_id", length = 32)
    private String teamId;

    @Column(name = "team_name", nullable = false, length = 100)
    private String teamName;

    @Column(name = "batch_id", nullable = false, length = 32)
    private String batchId;

    @Column(name = "assigned_poc_id", length = 32)
    private String assignedPocId;

    @Column(name = "interview_score", nullable = false, precision = 3, scale = 1)
    private BigDecimal interviewScore;

    @Column(name = "performance_score", nullable = false, precision = 3, scale = 1)
    private BigDecimal performanceScore = new BigDecimal("7.5");

    @Column(name = "missed_updates_days", nullable = false)
    private int missedUpdatesDays = 0;

    @Column(name = "selection_date", nullable = false)
    private LocalDate selectionDate = LocalDate.now();

    @Enumerated(EnumType.STRING)
    @Column(name = "final_decision", nullable = false, columnDefinition = "intern_decision_enum")
    private InternDecision finalDecision = InternDecision.under_review;

    @Column(columnDefinition = "TEXT")
    private String notes;

    @Column(name = "is_active", nullable = false)
    private boolean active = true;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt = Instant.now();

    public InternEntity() {}

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getCollege() { return college; }
    public void setCollege(String college) { this.college = college; }

    public RoleCategory getCategory() { return category; }
    public void setCategory(RoleCategory category) { this.category = category; }

    public String getDomain() { return domain; }
    public void setDomain(String domain) { this.domain = domain; }

    public String getTeamId() { return teamId; }
    public void setTeamId(String teamId) { this.teamId = teamId; }

    public String getTeamName() { return teamName; }
    public void setTeamName(String teamName) { this.teamName = teamName; }

    public String getBatchId() { return batchId; }
    public void setBatchId(String batchId) { this.batchId = batchId; }

    public String getAssignedPocId() { return assignedPocId; }
    public void setAssignedPocId(String assignedPocId) { this.assignedPocId = assignedPocId; }

    public BigDecimal getInterviewScore() { return interviewScore; }
    public void setInterviewScore(BigDecimal interviewScore) { this.interviewScore = interviewScore; }

    public BigDecimal getPerformanceScore() { return performanceScore; }
    public void setPerformanceScore(BigDecimal performanceScore) { this.performanceScore = performanceScore; }

    public int getMissedUpdatesDays() { return missedUpdatesDays; }
    public void setMissedUpdatesDays(int missedUpdatesDays) { this.missedUpdatesDays = missedUpdatesDays; }

    public LocalDate getSelectionDate() { return selectionDate; }
    public void setSelectionDate(LocalDate selectionDate) { this.selectionDate = selectionDate; }

    public InternDecision getFinalDecision() { return finalDecision; }
    public void setFinalDecision(InternDecision finalDecision) { this.finalDecision = finalDecision; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }

    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }

    public Instant getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }
}
