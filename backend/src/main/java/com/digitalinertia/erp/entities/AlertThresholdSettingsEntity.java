package com.digitalinertia.erp.entities;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.Instant;

@Entity
@Table(name = "alert_threshold_settings")
public class AlertThresholdSettingsEntity {

    @Id
    private Integer id = 1;

    @Column(name = "task_overdue_days", nullable = false)
    private int taskOverdueDays = 1;

    @Column(name = "intern_missed_update_days", nullable = false)
    private int internMissedUpdateDays = 2;

    @Column(name = "project_behind_schedule_percent", nullable = false)
    private int projectBehindSchedulePercent = 15;

    @Column(name = "employee_capacity_max_tasks", nullable = false)
    private int employeeCapacityMaxTasks = 4;

    @Column(name = "intern_low_score_cutoff", nullable = false, precision = 3, scale = 1)
    private BigDecimal internLowScoreCutoff = new BigDecimal("6.0");

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt = Instant.now();

    public AlertThresholdSettingsEntity() {}

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public int getTaskOverdueDays() { return taskOverdueDays; }
    public void setTaskOverdueDays(int taskOverdueDays) { this.taskOverdueDays = taskOverdueDays; }

    public int getInternMissedUpdateDays() { return internMissedUpdateDays; }
    public void setInternMissedUpdateDays(int internMissedUpdateDays) { this.internMissedUpdateDays = internMissedUpdateDays; }

    public int getProjectBehindSchedulePercent() { return projectBehindSchedulePercent; }
    public void setProjectBehindSchedulePercent(int projectBehindSchedulePercent) { this.projectBehindSchedulePercent = projectBehindSchedulePercent; }

    public int getEmployeeCapacityMaxTasks() { return employeeCapacityMaxTasks; }
    public void setEmployeeCapacityMaxTasks(int employeeCapacityMaxTasks) { this.employeeCapacityMaxTasks = employeeCapacityMaxTasks; }

    public BigDecimal getInternLowScoreCutoff() { return internLowScoreCutoff; }
    public void setInternLowScoreCutoff(BigDecimal internLowScoreCutoff) { this.internLowScoreCutoff = internLowScoreCutoff; }

    public Instant getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }
}
