package com.digitalinertia.erp.dto.department;

import java.util.ArrayList;
import java.util.List;

public class DepartmentDto {
    private String id;
    private String name;
    private String code;
    private String parentId;
    private String parentName;
    private String description;
    private boolean active;
    private List<DepartmentDto> subcategories = new ArrayList<>();

    public DepartmentDto() {
    }

    public DepartmentDto(String id, String name, String code, String parentId, String parentName, String description, boolean active) {
        this.id = id;
        this.name = name;
        this.code = code;
        this.parentId = parentId;
        this.parentName = parentName;
        this.description = description;
        this.active = active;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getParentId() {
        return parentId;
    }

    public void setParentId(String parentId) {
        this.parentId = parentId;
    }

    public String getParentName() {
        return parentName;
    }

    public void setParentName(String parentName) {
        this.parentName = parentName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    public List<DepartmentDto> getSubcategories() {
        return subcategories;
    }

    public void setSubcategories(List<DepartmentDto> subcategories) {
        this.subcategories = subcategories;
    }
}
