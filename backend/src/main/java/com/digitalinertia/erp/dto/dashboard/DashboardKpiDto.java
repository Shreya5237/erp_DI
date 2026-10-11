package com.digitalinertia.erp.dto.dashboard;

public class DashboardKpiDto {
    private long totalEmployees;
    private long activeInterns;
    private long pendingTasks;
    private long activeProjects;
    private long activeLeads;
    private long overdueTasks;
    private long delayedProjects;

    public DashboardKpiDto() {}

    public DashboardKpiDto(long totalEmployees, long activeInterns, long pendingTasks,
                           long activeProjects, long activeLeads, long overdueTasks, long delayedProjects) {
        this.totalEmployees = totalEmployees;
        this.activeInterns = activeInterns;
        this.pendingTasks = pendingTasks;
        this.activeProjects = activeProjects;
        this.activeLeads = activeLeads;
        this.overdueTasks = overdueTasks;
        this.delayedProjects = delayedProjects;
    }

    public long getTotalEmployees() { return totalEmployees; }
    public void setTotalEmployees(long totalEmployees) { this.totalEmployees = totalEmployees; }

    public long getActiveInterns() { return activeInterns; }
    public void setActiveInterns(long activeInterns) { this.activeInterns = activeInterns; }

    public long getPendingTasks() { return pendingTasks; }
    public void setPendingTasks(long pendingTasks) { this.pendingTasks = pendingTasks; }

    public long getActiveProjects() { return activeProjects; }
    public void setActiveProjects(long activeProjects) { this.activeProjects = activeProjects; }

    public long getActiveLeads() { return activeLeads; }
    public void setActiveLeads(long activeLeads) { this.activeLeads = activeLeads; }

    public long getOverdueTasks() { return overdueTasks; }
    public void setOverdueTasks(long overdueTasks) { this.overdueTasks = overdueTasks; }

    public long getDelayedProjects() { return delayedProjects; }
    public void setDelayedProjects(long delayedProjects) { this.delayedProjects = delayedProjects; }
}
