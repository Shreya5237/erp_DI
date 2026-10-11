package com.digitalinertia.erp.repositories;

import com.digitalinertia.erp.entities.TaskEntity;
import com.digitalinertia.erp.entities.enums.AssigneeType;
import com.digitalinertia.erp.entities.enums.TaskPriority;
import com.digitalinertia.erp.entities.enums.TaskStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface TaskRepository extends JpaRepository<TaskEntity, String> {
    List<TaskEntity> findByStatus(TaskStatus status);
    List<TaskEntity> findByPriority(TaskPriority priority);
    List<TaskEntity> findByAssignedToId(String assignedToId);
    List<TaskEntity> findByAssignedToIdAndAssigneeType(String assignedToId, AssigneeType assigneeType);
    List<TaskEntity> findByProjectId(String projectId);
    List<TaskEntity> findByAwaitingReviewTrue();

    @Query("SELECT t FROM TaskEntity t WHERE t.status != com.digitalinertia.erp.entities.enums.TaskStatus.completed AND t.dueDate < :today")
    List<TaskEntity> findOverdueTasks(@Param("today") LocalDate today);

    @Query("SELECT COUNT(t) FROM TaskEntity t WHERE t.status != com.digitalinertia.erp.entities.enums.TaskStatus.completed AND t.dueDate < :today")
    long countOverdueTasks(@Param("today") LocalDate today);

    @Query("SELECT COUNT(t) FROM TaskEntity t WHERE t.status IN (com.digitalinertia.erp.entities.enums.TaskStatus.todo, com.digitalinertia.erp.entities.enums.TaskStatus.in_progress, com.digitalinertia.erp.entities.enums.TaskStatus.needs_rework)")
    long countPendingTasks();

    @Query("SELECT COUNT(t) FROM TaskEntity t WHERE t.status = :status")
    long countByStatus(@Param("status") TaskStatus status);
}
