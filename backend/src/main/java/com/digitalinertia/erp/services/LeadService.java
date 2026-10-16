package com.digitalinertia.erp.services;

import com.digitalinertia.erp.common.ApiException;
import com.digitalinertia.erp.dto.sales.LeadCreateDto;
import com.digitalinertia.erp.dto.sales.SalesDashboardSummaryDto;
import com.digitalinertia.erp.dto.sales.StageTransitionDto;
import com.digitalinertia.erp.entities.AuditLogEntity;
import com.digitalinertia.erp.entities.LeadEntity;
import com.digitalinertia.erp.entities.ProjectEntity;
import com.digitalinertia.erp.entities.enums.LeadStage;
import com.digitalinertia.erp.entities.enums.ProjectStatus;
import com.digitalinertia.erp.repositories.AuditLogRepository;
import com.digitalinertia.erp.repositories.LeadRepository;
import com.digitalinertia.erp.repositories.ProjectRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.*;

@Service
@Transactional(readOnly = true)
public class LeadService {

    private final LeadRepository leadRepository;
    private final ProjectRepository projectRepository;
    private final AuditLogRepository auditLogRepository;

    public LeadService(
            LeadRepository leadRepository,
            ProjectRepository projectRepository,
            AuditLogRepository auditLogRepository) {
        this.leadRepository = leadRepository;
        this.projectRepository = projectRepository;
        this.auditLogRepository = auditLogRepository;
    }

    public List<LeadEntity> getAll(LeadStage stage, String ownerId) {
        if (stage != null) {
            return leadRepository.findByStage(stage);
        }
        if (ownerId != null && !ownerId.isBlank()) {
            return leadRepository.findByOwnerId(ownerId);
        }
        return leadRepository.findAll();
    }

    public LeadEntity getById(String id) {
        return leadRepository.findById(id)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Lead not found with id: " + id));
    }

    public boolean checkDuplicate(String companyName, String email) {
        if (companyName != null && !companyName.isBlank() && leadRepository.existsByCompanyNameIgnoreCase(companyName.trim())) {
            return true;
        }
        if (email != null && !email.isBlank() && leadRepository.existsByEmailIgnoreCase(email.trim())) {
            return true;
        }
        return false;
    }

    @Transactional
    public LeadEntity create(LeadCreateDto dto, String performedBy) {
        if (dto.getCompanyName() == null || dto.getCompanyName().isBlank()) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Company name is required");
        }
        if (dto.getClientName() == null || dto.getClientName().isBlank()) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Client contact name is required");
        }

        // Duplicate checks
        if (checkDuplicate(dto.getCompanyName(), dto.getEmail())) {
            throw new ApiException(HttpStatus.CONFLICT, "A lead with company '" + dto.getCompanyName() + "' or email already exists");
        }

        LeadEntity lead = new LeadEntity();
        lead.setId("LED-" + (500 + leadRepository.count() + 1));
        lead.setCompanyName(dto.getCompanyName().trim());
        lead.setClientName(dto.getClientName().trim());
        lead.setDomain(dto.getDomain() != null && !dto.getDomain().isBlank() ? dto.getDomain().trim() : "Enterprise Consulting");
        lead.setEmail(dto.getEmail());
        lead.setPhone(dto.getPhone());
        lead.setDealValue(dto.getDealValue() != null ? dto.getDealValue() : BigDecimal.ZERO);
        lead.setSource(dto.getSource() != null ? dto.getSource() : "Direct Outreach");
        lead.setNextFollowUp(dto.getNextFollowUp() != null ? dto.getNextFollowUp() : LocalDate.now().plusDays(3));
        lead.setNotes(dto.getNotes());
        lead.setOwnerId(dto.getOwnerId() != null ? dto.getOwnerId() : "EMP-112");
        lead.setOwnerName(dto.getOwnerName() != null ? dto.getOwnerName() : "Rajesh Kumar");
        lead.setStage(LeadStage.new_lead);
        lead.setActive(true);
        lead.setCreatedAt(Instant.now());
        lead.setUpdatedAt(Instant.now());

        LeadEntity saved = leadRepository.save(lead);
        auditLogRepository.save(new AuditLogEntity(
                "Lead Created",
                "Sales",
                "New prospect registered: " + saved.getCompanyName() + " (" + saved.getId() + ") by " + performedBy,
                performedBy
        ));
        return saved;
    }

    @Transactional
    public LeadEntity update(String id, LeadEntity updateData, String performedBy) {
        LeadEntity lead = getById(id);
        if (updateData.getCompanyName() != null && !updateData.getCompanyName().isBlank()) {
            lead.setCompanyName(updateData.getCompanyName());
        }
        if (updateData.getClientName() != null && !updateData.getClientName().isBlank()) {
            lead.setClientName(updateData.getClientName());
        }
        if (updateData.getDomain() != null) lead.setDomain(updateData.getDomain());
        if (updateData.getEmail() != null) lead.setEmail(updateData.getEmail());
        if (updateData.getPhone() != null) lead.setPhone(updateData.getPhone());
        if (updateData.getDealValue() != null) lead.setDealValue(updateData.getDealValue());
        if (updateData.getSource() != null) lead.setSource(updateData.getSource());
        if (updateData.getNextFollowUp() != null) lead.setNextFollowUp(updateData.getNextFollowUp());
        if (updateData.getNotes() != null) lead.setNotes(updateData.getNotes());
        lead.setUpdatedAt(Instant.now());

        LeadEntity saved = leadRepository.save(lead);
        auditLogRepository.save(new AuditLogEntity(
                "Lead Updated",
                "Sales",
                "Updated details for lead " + lead.getId() + " (" + lead.getCompanyName() + ")",
                performedBy
        ));
        return saved;
    }

    @Transactional
    public LeadEntity updateStage(String id, LeadStage stage) {
        StageTransitionDto dto = new StageTransitionDto();
        dto.setTargetStage(stage);
        return transitionStage(id, dto, "System");
    }

    @Transactional
    public LeadEntity transitionStage(String id, StageTransitionDto dto, String performedBy) {
        LeadEntity lead = getById(id);
        LeadStage target = dto.getTargetStage();

        if (target == null) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Target stage is required");
        }

        // Finance Review Gatekeeper check
        if (target == LeadStage.won) {
            boolean isHighValue = lead.getDealValue().compareTo(new BigDecimal("50000")) >= 0;
            boolean financeOk = lead.isFinanceApproved() || (dto.getFinanceApproved() != null && dto.getFinanceApproved());

            if (isHighValue && !financeOk) {
                throw new ApiException(HttpStatus.FORBIDDEN,
                        "Finance review approval is required before transitioning high-value deal " + id + " to WON.");
            }

            if (dto.getFinanceApproved() != null && dto.getFinanceApproved()) {
                lead.setFinanceApproved(true);
            }

            // Won Deal Project Handover: Reuse existing project or create new without duplication
            List<ProjectEntity> existingProjects = projectRepository.findByClientNameIgnoreCase(lead.getClientName());
            if (existingProjects != null && !existingProjects.isEmpty()) {
                ProjectEntity existing = existingProjects.get(0);
                lead.setHandoverProjectId(existing.getId());
            } else {
                ProjectEntity newProject = new ProjectEntity();
                newProject.setId("PRJ-" + (300 + projectRepository.count() + 1));
                newProject.setName(lead.getCompanyName() + " Solution Deployment");
                newProject.setClientName(lead.getClientName());
                newProject.setDomain(lead.getDomain());
                newProject.setStatus(ProjectStatus.in_progress);
                newProject.setProgressPercent(0);
                newProject.setPlannedProgressPercent(10);
                newProject.setBudget(lead.getDealValue());
                newProject.setStartDate(LocalDate.now());
                newProject.setDeadline(LocalDate.now().plusMonths(3));
                newProject.setHasBlockers(false);
                ProjectEntity savedProject = projectRepository.save(newProject);
                lead.setHandoverProjectId(savedProject.getId());
            }
        }

        // Lost reason requirement
        if (target == LeadStage.lost) {
            if (dto.getLostReason() == null || dto.getLostReason().isBlank()) {
                throw new ApiException(HttpStatus.BAD_REQUEST, "A specific lost reason must be provided when marking a deal as LOST");
            }
            lead.setLostReason(dto.getLostReason().trim());
        }

        lead.setStage(target);
        lead.setUpdatedAt(Instant.now());
        LeadEntity saved = leadRepository.save(lead);

        auditLogRepository.save(new AuditLogEntity(
                "Lead Stage Changed",
                "Sales",
                "Lead " + lead.getId() + " transitioned to stage " + target.name() + " by " + performedBy,
                performedBy
        ));

        return saved;
    }

    public SalesDashboardSummaryDto getDashboardSummary() {
        SalesDashboardSummaryDto summary = new SalesDashboardSummaryDto();
        summary.setTotalLeads(leadRepository.count());
        summary.setActiveOpportunities(leadRepository.countActiveLeads());
        summary.setWonRevenue(leadRepository.sumWonRevenue());
        summary.setExpectedRevenue(leadRepository.sumPipelineRevenue());
        summary.setFollowUpsDueToday(leadRepository.countFollowUpsDueToday(LocalDate.now()));
        summary.setOverdueFollowUps(leadRepository.findMissedFollowUps(LocalDate.now()).size());

        Map<String, Long> stageCounts = new HashMap<>();
        Map<String, BigDecimal> stageValues = new HashMap<>();

        for (LeadStage st : LeadStage.values()) {
            List<LeadEntity> list = leadRepository.findByStage(st);
            stageCounts.put(st.name(), (long) list.size());
            BigDecimal sum = list.stream().map(LeadEntity::getDealValue).reduce(BigDecimal.ZERO, BigDecimal::add);
            stageValues.put(st.name(), sum);
        }

        summary.setStageCounts(stageCounts);
        summary.setStageValues(stageValues);
        return summary;
    }
}
