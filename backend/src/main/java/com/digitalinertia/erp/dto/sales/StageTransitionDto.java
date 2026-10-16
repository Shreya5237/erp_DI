package com.digitalinertia.erp.dto.sales;

import com.digitalinertia.erp.entities.enums.LeadStage;

public class StageTransitionDto {
    private LeadStage targetStage;
    private String lostReason;
    private Boolean financeApproved;
    private String comments;

    public StageTransitionDto() {}

    public LeadStage getTargetStage() { return targetStage; }
    public void setTargetStage(LeadStage targetStage) { this.targetStage = targetStage; }

    public String getLostReason() { return lostReason; }
    public void setLostReason(String lostReason) { this.lostReason = lostReason; }

    public Boolean getFinanceApproved() { return financeApproved; }
    public void setFinanceApproved(Boolean financeApproved) { this.financeApproved = financeApproved; }

    public String getComments() { return comments; }
    public void setComments(String comments) { this.comments = comments; }
}
