package com.digitalinertia.erp.controllers;

import com.digitalinertia.erp.dto.sales.LeadCreateDto;
import com.digitalinertia.erp.dto.sales.SalesDashboardSummaryDto;
import com.digitalinertia.erp.dto.sales.StageTransitionDto;
import com.digitalinertia.erp.entities.LeadEntity;
import com.digitalinertia.erp.entities.enums.LeadStage;
import com.digitalinertia.erp.services.LeadService;
import com.digitalinertia.erp.services.SalesActivityService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class LeadControllerTest {

    @Mock
    private LeadService leadService;

    @Mock
    private SalesActivityService activityService;

    @InjectMocks
    private LeadController leadController;

    private LeadEntity sampleLead;

    @BeforeEach
    void setUp() {
        sampleLead = new LeadEntity();
        sampleLead.setId("LED-501");
        sampleLead.setCompanyName("GreenTech Solutions");
        sampleLead.setClientName("Vikramaditya Rao");
        sampleLead.setDomain("IT Consulting");
        sampleLead.setEmail("vikram@greentech.in");
        sampleLead.setStage(LeadStage.new_lead);
        sampleLead.setDealValue(new BigDecimal("35000.00"));
        sampleLead.setNextFollowUp(LocalDate.now().plusDays(2));
    }

    @Test
    @DisplayName("GET /leads returns all leads successfully")
    void testGetAllLeads() {
        when(leadService.getAll(null, null)).thenReturn(List.of(sampleLead));

        ResponseEntity<?> response = leadController.getAll(null, null);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        verify(leadService, times(1)).getAll(null, null);
    }

    @Test
    @DisplayName("GET /leads/dashboard-summary retrieves real persisted sales metrics")
    void testGetDashboardSummary() {
        SalesDashboardSummaryDto summary = new SalesDashboardSummaryDto();
        summary.setTotalLeads(14);
        summary.setActiveOpportunities(12);
        summary.setWonRevenue(new BigDecimal("110000.00"));
        summary.setExpectedRevenue(new BigDecimal("685000.00"));
        summary.setFollowUpsDueToday(2);
        summary.setOverdueFollowUps(4);

        when(leadService.getDashboardSummary()).thenReturn(summary);

        ResponseEntity<?> response = leadController.getDashboardSummary();

        assertEquals(HttpStatus.OK, response.getStatusCode());
        verify(leadService, times(1)).getDashboardSummary();
    }

    @Test
    @DisplayName("GET /leads/check-duplicate returns correct duplicate check result")
    void testCheckDuplicate() {
        when(leadService.checkDuplicate("GreenTech Solutions", null)).thenReturn(true);

        ResponseEntity<?> response = leadController.checkDuplicate("GreenTech Solutions", null);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        verify(leadService, times(1)).checkDuplicate("GreenTech Solutions", null);
    }

    @Test
    @DisplayName("POST /leads creates lead successfully")
    void testCreateLead() {
        LeadCreateDto dto = new LeadCreateDto();
        dto.setCompanyName("Zenith Robotics");
        dto.setClientName("Dr. Anita Sen");
        dto.setDealValue(new BigDecimal("75000.00"));

        when(leadService.create(any(LeadCreateDto.class), anyString())).thenReturn(sampleLead);

        ResponseEntity<?> response = leadController.create(dto, null);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        verify(leadService, times(1)).create(any(LeadCreateDto.class), anyString());
    }

    @Test
    @DisplayName("POST /leads/{id}/transition handles stage progression")
    void testTransitionStage() {
        StageTransitionDto dto = new StageTransitionDto();
        dto.setTargetStage(LeadStage.proposal);

        when(leadService.transitionStage(eq("LED-501"), any(StageTransitionDto.class), anyString()))
                .thenReturn(sampleLead);

        ResponseEntity<?> response = leadController.transition("LED-501", dto, null);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        verify(leadService, times(1)).transitionStage(eq("LED-501"), any(StageTransitionDto.class), anyString());
    }
}
