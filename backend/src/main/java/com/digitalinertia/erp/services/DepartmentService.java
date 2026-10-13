package com.digitalinertia.erp.services;

import com.digitalinertia.erp.common.ApiException;
import com.digitalinertia.erp.dto.department.DepartmentDto;
import com.digitalinertia.erp.entities.DepartmentEntity;
import com.digitalinertia.erp.repositories.DepartmentRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional(readOnly = true)
public class DepartmentService {

    public static final List<String> APPROVED_ROOT_DEPARTMENTS = Arrays.asList(
            "Finance", "Sales", "Marketing", "HR", "Technical"
    );

    private final DepartmentRepository departmentRepository;

    public DepartmentService(DepartmentRepository departmentRepository) {
        this.departmentRepository = departmentRepository;
    }

    public List<DepartmentDto> getDepartmentTree() {
        List<DepartmentEntity> roots = departmentRepository.findByParentIdIsNullAndActiveTrueOrderByNameAsc();
        return roots.stream().map(this::mapToTreeDto).collect(Collectors.toList());
    }

    public List<DepartmentDto> getRootDepartments() {
        return departmentRepository.findByParentIdIsNullAndActiveTrueOrderByNameAsc().stream()
                .map(this::mapToDto)
                .collect(Collectors.toList());
    }

    public List<DepartmentDto> getSubcategories(String parentId) {
        DepartmentEntity parent = departmentRepository.findById(parentId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Parent department not found with id: " + parentId));

        if (!parent.isTopLevel()) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Department " + parentId + " is a subcategory, not a top-level department.");
        }

        return departmentRepository.findByParentIdAndActiveTrueOrderByNameAsc(parentId).stream()
                .map(this::mapToDto)
                .collect(Collectors.toList());
    }

    public DepartmentEntity getById(String id) {
        return departmentRepository.findById(id)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Department not found with id: " + id));
    }

    public void validateDepartmentAssignment(String departmentId, String subDepartmentId) {
        if (departmentId == null || departmentId.trim().isEmpty()) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Primary department ID is required.");
        }

        DepartmentEntity root = departmentRepository.findById(departmentId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Department not found with id: " + departmentId));

        if (!root.isTopLevel()) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Assigned primary department must be a top-level department: " + root.getName());
        }

        if (!APPROVED_ROOT_DEPARTMENTS.contains(root.getName())) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Department '" + root.getName() + "' is not one of the 5 approved root departments.");
        }

        if (subDepartmentId != null && !subDepartmentId.trim().isEmpty()) {
            DepartmentEntity sub = departmentRepository.findById(subDepartmentId)
                    .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Subcategory not found with id: " + subDepartmentId));

            if (sub.isTopLevel()) {
                throw new ApiException(HttpStatus.BAD_REQUEST, "Specified subcategory is a root department, not a child: " + sub.getName());
            }

            if (!departmentId.equals(sub.getParentId())) {
                throw new ApiException(HttpStatus.BAD_REQUEST,
                        "Subcategory '" + sub.getName() + "' does not belong to root department '" + root.getName() + "'.");
            }
        }
    }

    private DepartmentDto mapToDto(DepartmentEntity entity) {
        String parentName = entity.getParent() != null ? entity.getParent().getName() : null;
        return new DepartmentDto(
                entity.getId(),
                entity.getName(),
                entity.getCode(),
                entity.getParentId(),
                parentName,
                entity.getDescription(),
                entity.isActive()
        );
    }

    private DepartmentDto mapToTreeDto(DepartmentEntity root) {
        DepartmentDto dto = mapToDto(root);
        List<DepartmentEntity> subs = departmentRepository.findByParentIdAndActiveTrueOrderByNameAsc(root.getId());
        dto.setSubcategories(subs.stream().map(this::mapToDto).collect(Collectors.toList()));
        return dto;
    }
}
