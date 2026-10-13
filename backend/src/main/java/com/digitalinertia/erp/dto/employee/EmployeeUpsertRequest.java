package com.digitalinertia.erp.dto.employee;

import com.digitalinertia.erp.entities.enums.RoleCategory;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public class EmployeeUpsertRequest {

    @NotBlank(message = "Employee name is required")
    private String name;

    @NotBlank(message = "Email is required")
    @Email(message = "Valid email is required")
    private String email;

    private String phone;

    @NotBlank(message = "Role ID is required")
    private String roleId;

    @NotBlank(message = "Role title is required")
    private String roleTitle;

    private String teamId;

    @NotBlank(message = "Team name is required")
    private String teamName;

    @NotNull(message = "Category is required")
    private RoleCategory category;

    @NotBlank(message = "Primary Department ID is required")
    private String departmentId;

    private String subDepartmentId;

    private boolean poc = false;

    private int maxTaskCapacity = 5;

    public EmployeeUpsertRequest() {
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getRoleId() {
        return roleId;
    }

    public void setRoleId(String roleId) {
        this.roleId = roleId;
    }

    public String getRoleTitle() {
        return roleTitle;
    }

    public void setRoleTitle(String roleTitle) {
        this.roleTitle = roleTitle;
    }

    public String getTeamId() {
        return teamId;
    }

    public void setTeamId(String teamId) {
        this.teamId = teamId;
    }

    public String getTeamName() {
        return teamName;
    }

    public void setTeamName(String teamName) {
        this.teamName = teamName;
    }

    public RoleCategory getCategory() {
        return category;
    }

    public void setCategory(RoleCategory category) {
        this.category = category;
    }

    public String getDepartmentId() {
        return departmentId;
    }

    public void setDepartmentId(String departmentId) {
        this.departmentId = departmentId;
    }

    public String getSubDepartmentId() {
        return subDepartmentId;
    }

    public void setSubDepartmentId(String subDepartmentId) {
        this.subDepartmentId = subDepartmentId;
    }

    public boolean isPoc() {
        return poc;
    }

    public void setPoc(boolean poc) {
        this.poc = poc;
    }

    public int getMaxTaskCapacity() {
        return maxTaskCapacity;
    }

    public void setMaxTaskCapacity(int maxTaskCapacity) {
        this.maxTaskCapacity = maxTaskCapacity;
    }
}
