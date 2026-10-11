package com.digitalinertia.erp.entities;

import com.digitalinertia.erp.entities.enums.RoleCategory;
import jakarta.persistence.*;
import java.time.Instant;

@Entity
@Table(name = "company_roles")
public class CompanyRoleEntity {

    @Id
    @Column(length = 32)
    private String id;

    @Column(nullable = false, unique = true, length = 100)
    private String name;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, columnDefinition = "role_category_enum")
    private RoleCategory category;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(name = "is_active", nullable = false)
    private boolean active = true;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt = Instant.now();

    public CompanyRoleEntity() {}

    public CompanyRoleEntity(String id, String name, RoleCategory category, String description) {
        this.id = id;
        this.name = name;
        this.category = category;
        this.description = description;
        this.active = true;
        this.createdAt = Instant.now();
        this.updatedAt = Instant.now();
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public RoleCategory getCategory() { return category; }
    public void setCategory(RoleCategory category) { this.category = category; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }

    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }

    public Instant getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }
}
