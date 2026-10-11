package com.digitalinertia.erp.entities;

import com.digitalinertia.erp.entities.enums.AssigneeType;
import com.digitalinertia.erp.entities.enums.TaskPriority;
import com.digitalinertia.erp.entities.enums.TaskStatus;
import jakarta.persistence.*;
import java.time.Instant;
import java.time.LocalDate;

@Entity
@Table(name = "tasks")
public class TaskEntity {

    @Id
    @Column(length = 32)
    private String id;

    @Column(nullable = false, length = 200)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(nullable = false, length = 100)
    private String domain;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, columnDefinition = "task_status_enum")
    private TaskStatus status = TaskStatus.todo;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, columnDefinition = "task_priority_enum")
    private TaskPriority priority = TaskPriority.medium;

    @Column(name = "assigned_to_id", nullable = false, length = 32)
    private String assignedToId;

    @Column(name = "assigned_to_name", nullable = false, length = 100)
    private String assignedToName;

    @Enumerated(EnumType.STRING)
    @Column(name = "assignee_type", nullable = false, columnDefinition = "assignee_type_enum")
    private AssigneeType assigneeType = AssigneeType.employee;

    @Column(name = "assigned_by_id", length = 32)
    private String assignedById;

    @Column(name = "assigned_by_name", length = 100)
    private String assignedByName;

    @Column(name = "project_id", length = 32)
    private String projectId;

    @Column(name = "project_name", length = 150)
    private String projectName;

    @Column(name = "due_date", nullable = false)
    private LocalDate dueDate;

    @Column(name = "awaiting_review", nullable = false)
    private boolean awaitingReview = false;

    @Column(name = "completed_at")
    private Instant completedAt;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt = Instant.now();

    public TaskEntity() {}

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getDomain() { return domain; }
    public void setDomain(String domain) { this.domain = domain; }

    public TaskStatus getStatus() { return status; }
    public void setStatus(TaskStatus status) { this.status = status; }

    public TaskPriority getPriority() { return priority; }
    public void setPriority(TaskPriority priority) { this.priority = priority; }

    public String getAssignedToId() { return assignedToId; }
    public void setAssignedToId(String assignedToId) { this.assignedToId = assignedToId; }

    public String getAssignedToName() { return assignedToName; }
    public void setAssignedToName(String assignedToName) { this.assignedToName = assignedToName; }

    public AssigneeType getAssigneeType() { return assigneeType; }
    public void setAssigneeType(AssigneeType assigneeType) { this.assigneeType = assigneeType; }

    public String getAssignedById() { return assignedById; }
    public void setAssignedById(String assignedById) { this.assignedById = assignedById; }

    public String getAssignedByName() { return assignedByName; }
    public void setAssignedByName(String assignedByName) { this.assignedByName = assignedByName; }

    public String getProjectId() { return projectId; }
    public void setProjectId(String projectId) { this.projectId = projectId; }

    public String getProjectName() { return projectName; }
    public void setProjectName(String projectName) { this.projectName = projectName; }

    public LocalDate getDueDate() { return dueDate; }
    public void setDueDate(LocalDate dueDate) { this.dueDate = dueDate; }

    public boolean isAwaitingReview() { return awaitingReview; }
    public void setAwaitingReview(boolean awaitingReview) { this.awaitingReview = awaitingReview; }

    public Instant getCompletedAt() { return completedAt; }
    public void setCompletedAt(Instant completedAt) { this.completedAt = completedAt; }

    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }

    public Instant getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }
}
