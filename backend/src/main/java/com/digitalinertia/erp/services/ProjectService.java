package com.digitalinertia.erp.services;

import com.digitalinertia.erp.common.ApiException;
import com.digitalinertia.erp.entities.ProjectEntity;
import com.digitalinertia.erp.entities.enums.ProjectStatus;
import com.digitalinertia.erp.repositories.ProjectRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional(readOnly = true)
public class ProjectService {

    private final ProjectRepository projectRepository;

    public ProjectService(ProjectRepository projectRepository) {
        this.projectRepository = projectRepository;
    }

    public List<ProjectEntity> getAll(ProjectStatus status) {
        if (status != null) {
            return projectRepository.findByStatus(status);
        }
        return projectRepository.findAll();
    }

    public ProjectEntity getById(String id) {
        return projectRepository.findById(id)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Project not found with id: " + id));
    }

    public List<ProjectEntity> getActiveProjects() {
        return projectRepository.findActiveProjects();
    }
}
