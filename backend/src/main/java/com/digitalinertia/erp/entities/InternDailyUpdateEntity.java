package com.digitalinertia.erp.entities;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;

@Entity
@Table(name = "intern_daily_updates", uniqueConstraints = {
    @UniqueConstraint(name = "uq_intern_daily_date", columnNames = {"intern_id", "update_date"})
})
public class InternDailyUpdateEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "intern_id", nullable = false, length = 32)
    private String internId;

    @Column(name = "update_date", nullable = false)
    private LocalDate updateDate = LocalDate.now();

    @Column(name = "tasks_completed", nullable = false, columnDefinition = "TEXT")
    private String tasksCompleted;

    @Column(columnDefinition = "TEXT")
    private String blockers;

    @Column(name = "hours_logged", nullable = false, precision = 4, scale = 1)
    private BigDecimal hoursLogged = new BigDecimal("8.0");

    @Column(nullable = false, length = 20)
    private String status = "submitted";

    @Column(name = "submitted_at", nullable = false, updatable = false)
    private Instant submittedAt = Instant.now();

    public InternDailyUpdateEntity() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getInternId() { return internId; }
    public void setInternId(String internId) { this.internId = internId; }

    public LocalDate getUpdateDate() { return updateDate; }
    public void setUpdateDate(LocalDate updateDate) { this.updateDate = updateDate; }

    public String getTasksCompleted() { return tasksCompleted; }
    public void setTasksCompleted(String tasksCompleted) { this.tasksCompleted = tasksCompleted; }

    public String getBlockers() { return blockers; }
    public void setBlockers(String blockers) { this.blockers = blockers; }

    public BigDecimal getHoursLogged() { return hoursLogged; }
    public void setHoursLogged(BigDecimal hoursLogged) { this.hoursLogged = hoursLogged; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Instant getSubmittedAt() { return submittedAt; }
    public void setSubmittedAt(Instant submittedAt) { this.submittedAt = submittedAt; }
}
