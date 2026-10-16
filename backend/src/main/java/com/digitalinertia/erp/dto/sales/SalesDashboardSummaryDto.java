package com.digitalinertia.erp.dto.sales;

import java.math.BigDecimal;
import java.util.Map;

public class SalesDashboardSummaryDto {
    private long totalLeads;
    private long activeOpportunities;
    private BigDecimal wonRevenue;
    private BigDecimal expectedRevenue;
    private long followUpsDueToday;
    private long overdueFollowUps;
    private Map<String, Long> stageCounts;
    private Map<String, BigDecimal> stageValues;

    public SalesDashboardSummaryDto() {}

    public long getTotalLeads() { return totalLeads; }
    public void setTotalLeads(long totalLeads) { this.totalLeads = totalLeads; }

    public long getActiveOpportunities() { return activeOpportunities; }
    public void setActiveOpportunities(long activeOpportunities) { this.activeOpportunities = activeOpportunities; }

    public BigDecimal getWonRevenue() { return wonRevenue; }
    public void setWonRevenue(BigDecimal wonRevenue) { this.wonRevenue = wonRevenue; }

    public BigDecimal getExpectedRevenue() { return expectedRevenue; }
    public void setExpectedRevenue(BigDecimal expectedRevenue) { this.expectedRevenue = expectedRevenue; }

    public long getFollowUpsDueToday() { return followUpsDueToday; }
    public void setFollowUpsDueToday(long followUpsDueToday) { this.followUpsDueToday = followUpsDueToday; }

    public long getOverdueFollowUps() { return overdueFollowUps; }
    public void setOverdueFollowUps(long overdueFollowUps) { this.overdueFollowUps = overdueFollowUps; }

    public Map<String, Long> getStageCounts() { return stageCounts; }
    public void setStageCounts(Map<String, Long> stageCounts) { this.stageCounts = stageCounts; }

    public Map<String, BigDecimal> getStageValues() { return stageValues; }
    public void setStageValues(Map<String, BigDecimal> stageValues) { this.stageValues = stageValues; }
}
