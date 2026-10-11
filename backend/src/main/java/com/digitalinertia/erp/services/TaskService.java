package com.digitalinertia.erp.services;

import com.digitalinertia.erp.common.ApiException;
import com.digitalinertia.erp.entities.TaskEntity;
import com.digitalinertia.erp.entities.enums.AssigneeType;
import com.digitalinertia.erp.entities.enums.TaskPriority;
import com.digitalinertia.erp.entities.enums.TaskStatus;
import com.digitalinertia.erp.repositories.TaskRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Service
@Transactional(readOnly = true)
public class TaskService {

    private final TaskRepository taskRepository;

    public TaskService(TaskRepository taskRepository) {
        this.taskRepository = taskRepository;
    }

    public List<TaskEntity> getAll(TaskStatus status, TaskPriority priority, String assignedToId, AssigneeType assigneeType, String projectId) {
        if (status != null) {
            return taskRepository.findByStatus(status);
        }
        if (priority != null) {
            return taskRepository.findByPriority(priority);
        }
        if (assignedToId != null && assigneeType != null) {
            return taskRepository.findByAssignedToIdAndAssigneeType(assignedToId, assigneeType);
        }
        if (assignedToId != null) {
            return taskRepository.findByAssignedToId(assignedToId);
        }
        if (projectId != null) {
            return taskRepository.findByProjectId(projectId);
        }
        return taskRepository.findAll();
    }

    public TaskEntity getById(String id) {
        return taskRepository.findById(id)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Task not found with id: " + id));
    }

    @Transactional
    public TaskEntity create(TaskEntity task) {
        if (task.getId() == null || task.getId().isBlank()) {
            task.setId("TSK-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase());
        }
        task.setCreatedAt(Instant.now());
        task.setUpdatedAt(Instant.now());
        return taskRepository.save(task);
    }

    @Transactional
    public TaskEntity updateStatus(String id, TaskStatus newStatus) {
        TaskEntity task = getById(id);
        task.setStatus(newStatus);
        if (newStatus == TaskStatus.completed) {
            task.setCompletedAt(Instant.now());
            task.setAwaitingReview(false);
        }
        task.setUpdatedAt(Instant.now());
        return taskRepository.save(task);
    }

    @Transactional
    public TaskEntity setAwaitingReview(String id, boolean awaitingReview) {
        TaskEntity task = getById(id);
        task.setAwaitingReview(awaitingReview);
        task.setUpdatedAt(Instant.now());
        return taskRepository.save(task);
    }
}
