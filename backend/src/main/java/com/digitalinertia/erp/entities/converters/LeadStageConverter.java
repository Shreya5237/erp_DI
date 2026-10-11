package com.digitalinertia.erp.entities.converters;

import com.digitalinertia.erp.entities.enums.LeadStage;
import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;

@Converter(autoApply = true)
public class LeadStageConverter implements AttributeConverter<LeadStage, String> {

    @Override
    public String convertToDatabaseColumn(LeadStage attribute) {
        if (attribute == null) {
            return null;
        }
        return attribute.toDb();
    }

    @Override
    public LeadStage convertToEntityAttribute(String dbData) {
        if (dbData == null || dbData.isBlank()) {
            return null;
        }
        return LeadStage.fromDb(dbData);
    }
}
