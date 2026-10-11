package com.digitalinertia.erp.entities;

import com.digitalinertia.erp.entities.enums.ProjectStatus;
import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;

@Entity
@Table(name = "projects")
public class ProjectEntity {

    @Id
    @Column(length = 32)
    private String id;

    @Column(nullable = false, length = 150)
    private String name;

    @Column(name = "client_name", nullable = false, length = 150)
    private String clientName;

    @Column(nullable = false, length = 100)
    private String domain;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, columnDefinition = "project_status_enum")
    private ProjectStatus status = ProjectStatus.in_progress;

    @Column(name = "progress_percent", nullable = false)
    private int progressPercent = 0;

    @Column(name = "planned_progress_percent", nullable = false)
    private int plannedProgressPercent = 0;

    @Column(name = "behind_schedule_percent", insertable = false, updatable = false)
    private Integer behindSchedulePercent;

    @Column(name = "owner_id", length = 32)
    private String ownerId;

    @Column(name = "team_id", length = 32)
    private String teamId;

    @Column(nullable = false, precision = 12, scale = 2)
    private BigDecimal budget = BigDecimal.ZERO;

    @Column(name = "start_date", nullable = false)
    private LocalDate startDate = LocalDate.now();

    @Column(nullable = false)
    private LocalDate deadline;

    @Column(name = "has_blockers", nullable = false)
    private boolean hasBlockers = false;

    @Column(name = "blocker_details", columnDefinition = "TEXT")
    private String blockerDetails;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt = Instant.now();

    public ProjectEntity() {}

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getClientName() { return clientName; }
    public void setClientName(String clientName) { this.clientName = clientName; }

    public String getDomain() { return domain; }
    public void setDomain(String domain) { this.domain = domain; }

    public ProjectStatus getStatus() { return status; }
    public void setStatus(ProjectStatus status) { this.status = status; }

    public int getProgressPercent() { return progressPercent; }
    public void setProgressPercent(int progressPercent) { this.progressPercent = progressPercent; }

    public int getPlannedProgressPercent() { return plannedProgressPercent; }
    public void setPlannedProgressPercent(int plannedProgressPercent) { this.plannedProgressPercent = plannedProgressPercent; }

    public Integer getBehindSchedulePercent() { return behindSchedulePercent; }
    public void setBehindSchedulePercent(Integer behindSchedulePercent) { this.behindSchedulePercent = behindSchedulePercent; }

    public String getOwnerId() { return ownerId; }
    public void setOwnerId(String ownerId) { this.ownerId = ownerId; }

    public String getTeamId() { return teamId; }
    public void setTeamId(String teamId) { this.teamId = teamId; }

    public BigDecimal getBudget() { return budget; }
    public void setBudget(BigDecimal budget) { this.budget = budget; }

    public LocalDate getStartDate() { return startDate; }
    public void setStartDate(LocalDate startDate) { this.startDate = startDate; }

    public LocalDate getDeadline() { return deadline; }
    public void setDeadline(LocalDate deadline) { this.deadline = deadline; }

    public boolean isHasBlockers() { return hasBlockers; }
    public void setHasBlockers(boolean hasBlockers) { this.hasBlockers = hasBlockers; }

    public String getBlockerDetails() { return blockerDetails; }
    public void setBlockerDetails(String blockerDetails) { this.blockerDetails = blockerDetails; }

    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }

    public Instant getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }
}
