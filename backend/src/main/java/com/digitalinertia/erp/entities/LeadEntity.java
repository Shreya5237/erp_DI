package com.digitalinertia.erp.entities;

import com.digitalinertia.erp.entities.enums.LeadStage;
import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;

@Entity
@Table(name = "leads")
public class LeadEntity {

    @Id
    @Column(length = 32)
    private String id;

    @Column(name = "company_name", nullable = false, length = 150)
    private String companyName;

    @Column(name = "client_name", nullable = false, length = 100)
    private String clientName;

    @Column(nullable = false, length = 100)
    private String domain;

    @Column(length = 150)
    private String email;

    @Column(length = 30)
    private String phone;

    @Column(nullable = false, length = 30)
    private LeadStage stage = LeadStage.new_lead;

    @Column(name = "deal_value", nullable = false, precision = 12, scale = 2)
    private BigDecimal dealValue = BigDecimal.ZERO;

    @Column(name = "owner_id", length = 32)
    private String ownerId;

    @Column(name = "owner_name", nullable = false, length = 100)
    private String ownerName;

    @Column(name = "next_follow_up", nullable = false)
    private LocalDate nextFollowUp;

    @Column(nullable = false, length = 100)
    private String source = "Direct Outreach";

    @Column(columnDefinition = "TEXT")
    private String notes;

    @Column(name = "is_active", nullable = false)
    private boolean active = true;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt = Instant.now();

    public LeadEntity() {}

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getCompanyName() { return companyName; }
    public void setCompanyName(String companyName) { this.companyName = companyName; }

    public String getClientName() { return clientName; }
    public void setClientName(String clientName) { this.clientName = clientName; }

    public String getDomain() { return domain; }
    public void setDomain(String domain) { this.domain = domain; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public LeadStage getStage() { return stage; }
    public void setStage(LeadStage stage) { this.stage = stage; }

    public BigDecimal getDealValue() { return dealValue; }
    public void setDealValue(BigDecimal dealValue) { this.dealValue = dealValue; }

    public String getOwnerId() { return ownerId; }
    public void setOwnerId(String ownerId) { this.ownerId = ownerId; }

    public String getOwnerName() { return ownerName; }
    public void setOwnerName(String ownerName) { this.ownerName = ownerName; }

    public LocalDate getNextFollowUp() { return nextFollowUp; }
    public void setNextFollowUp(LocalDate nextFollowUp) { this.nextFollowUp = nextFollowUp; }

    public String getSource() { return source; }
    public void setSource(String source) { this.source = source; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }

    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }

    public Instant getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }
}
