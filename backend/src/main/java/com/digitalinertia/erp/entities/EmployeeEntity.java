package com.digitalinertia.erp.entities;

import com.digitalinertia.erp.entities.enums.RoleCategory;
import jakarta.persistence.*;
import java.time.Instant;
import java.time.LocalDate;

@Entity
@Table(name = "employees")
public class EmployeeEntity {

    @Id
    @Column(length = 32)
    private String id;

    @Column(nullable = false, length = 100)
    private String name;

    @Column(nullable = false, unique = true, length = 150)
    private String email;

    @Column(length = 30)
    private String phone;

    @Column(name = "role_id", nullable = false, length = 32)
    private String roleId;

    @Column(name = "role_title", nullable = false, length = 100)
    private String roleTitle;

    @Column(name = "team_id", length = 32)
    private String teamId;

    @Column(name = "team_name", nullable = false, length = 100)
    private String teamName;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, columnDefinition = "role_category_enum")
    private RoleCategory category;

    @Column(name = "is_active", nullable = false)
    private boolean active = true;

    @Column(name = "is_poc", nullable = false)
    private boolean poc = false;

    @Column(name = "max_task_capacity", nullable = false)
    private int maxTaskCapacity = 5;

    @Column(name = "current_active_tasks", nullable = false)
    private int currentActiveTasks = 0;

    @Column(name = "avatar_url", columnDefinition = "TEXT")
    private String avatarUrl;

    @Column(name = "joined_date", nullable = false)
    private LocalDate joinedDate = LocalDate.now();

    @Column(name = "last_active_at", nullable = false)
    private Instant lastActiveAt = Instant.now();

    @Column(name = "department_id", nullable = false, length = 32)
    private String departmentId;

    @Column(name = "sub_department_id", length = 32)
    private String subDepartmentId;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "department_id", insertable = false, updatable = false)
    private DepartmentEntity department;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "sub_department_id", insertable = false, updatable = false)
    private DepartmentEntity subDepartment;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt = Instant.now();

    public EmployeeEntity() {}

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getRoleId() { return roleId; }
    public void setRoleId(String roleId) { this.roleId = roleId; }

    public String getRoleTitle() { return roleTitle; }
    public void setRoleTitle(String roleTitle) { this.roleTitle = roleTitle; }

    public String getTeamId() { return teamId; }
    public void setTeamId(String teamId) { this.teamId = teamId; }

    public String getTeamName() { return teamName; }
    public void setTeamName(String teamName) { this.teamName = teamName; }

    public RoleCategory getCategory() { return category; }
    public void setCategory(RoleCategory category) { this.category = category; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }

    public boolean isPoc() { return poc; }
    public void setPoc(boolean poc) { this.poc = poc; }

    public int getMaxTaskCapacity() { return maxTaskCapacity; }
    public void setMaxTaskCapacity(int maxTaskCapacity) { this.maxTaskCapacity = maxTaskCapacity; }

    public int getCurrentActiveTasks() { return currentActiveTasks; }
    public void setCurrentActiveTasks(int currentActiveTasks) { this.currentActiveTasks = currentActiveTasks; }

    public String getAvatarUrl() { return avatarUrl; }
    public void setAvatarUrl(String avatarUrl) { this.avatarUrl = avatarUrl; }

    public LocalDate getJoinedDate() { return joinedDate; }
    public void setJoinedDate(LocalDate joinedDate) { this.joinedDate = joinedDate; }

    public Instant getLastActiveAt() { return lastActiveAt; }
    public void setLastActiveAt(Instant lastActiveAt) { this.lastActiveAt = lastActiveAt; }

    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }

    public Instant getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }

    public String getDepartmentId() { return departmentId; }
    public void setDepartmentId(String departmentId) { this.departmentId = departmentId; }

    public String getSubDepartmentId() { return subDepartmentId; }
    public void setSubDepartmentId(String subDepartmentId) { this.subDepartmentId = subDepartmentId; }

    public DepartmentEntity getDepartment() { return department; }
    public void setDepartment(DepartmentEntity department) {
        this.department = department;
        if (department != null) {
            this.departmentId = department.getId();
        }
    }

    public DepartmentEntity getSubDepartment() { return subDepartment; }
    public void setSubDepartment(DepartmentEntity subDepartment) {
        this.subDepartment = subDepartment;
        if (subDepartment != null) {
            this.subDepartmentId = subDepartment.getId();
        }
    }

    public String getDepartmentName() {
        return department != null ? department.getName() : null;
    }

    public String getSubDepartmentName() {
        return subDepartment != null ? subDepartment.getName() : null;
    }
}
