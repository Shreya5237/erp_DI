package com.digitalinertia.erp.entities.enums;

public enum LeadStage {
    new_lead,
    contacted,
    proposal,
    qualified,
    won,
    lost;

    public static LeadStage fromDb(String value) {
        if ("new".equalsIgnoreCase(value)) return new_lead;
        return LeadStage.valueOf(value.toLowerCase());
    }

    public String toDb() {
        if (this == new_lead) return "new";
        return this.name();
    }
}
