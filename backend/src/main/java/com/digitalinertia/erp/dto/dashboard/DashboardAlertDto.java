package com.digitalinertia.erp.dto.dashboard;

import com.digitalinertia.erp.entities.enums.AlertSeverity;

public class DashboardAlertDto {
    private String alertId;
    private String module;
    private String title;
    private String description;
    private AlertSeverity severity;
    private int affectedCount;

    public DashboardAlertDto() {}

    public DashboardAlertDto(String alertId, String module, String title, String description,
                             AlertSeverity severity, int affectedCount) {
        this.alertId = alertId;
        this.module = module;
        this.title = title;
        this.description = description;
        this.severity = severity;
        this.affectedCount = affectedCount;
    }

    public String getAlertId() { return alertId; }
    public void setAlertId(String alertId) { this.alertId = alertId; }

    public String getModule() { return module; }
    public void setModule(String module) { this.module = module; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public AlertSeverity getSeverity() { return severity; }
    public void setSeverity(AlertSeverity severity) { this.severity = severity; }

    public int getAffectedCount() { return affectedCount; }
    public void setAffectedCount(int affectedCount) { this.affectedCount = affectedCount; }
}
